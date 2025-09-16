// SPDX-License-Identifier: MPL-2.0

def KEY_LEN: size = 16z;

fn put_le64(dst: []u8, x: u64) void = {
	for (let i = 0z; i < 8z; i += 1) {
		dst[i] = ((x >> (8u64 * (i: u64))) & 0xFFu64): u8;
	};
};

type oracle = []nullable *opaque;

fn must_set(m: *map, key: []u8, v: *opaque) void = {
	match (set(m, key, v)) {
	case void => void;
	case nomem => abort("set: out of memory");
	};
};
fn must_get(m: *map, key: []u8) (*opaque | void) = get(m, key);
fn must_del(m: *map, key: []u8) (*opaque | void) = del(m, key);

export fn stress_test(m: *map, key_space: size) void = {
	let empty: [KEY_LEN]u8 = [0...];
	let keybufs: [][KEY_LEN]u8 = alloc([empty...], key_space)!;
	let keys: [][]u8 = alloc([[0...]...], key_space)!;

	for (let i = 0z; i < key_space; i += 1) {
		for (let j = 8z; j < KEY_LEN; j += 1) keybufs[i][j] = 0xABu8;
		put_le64((keybufs[i][..8]), (i: u64));
		keys[i] = keybufs[i][..];
	};

	let vals: []int = alloc([0...], key_space)!;
	for (let i = 0z; i < key_space; i += 1) vals[i] = (i: int);

	let exp: oracle = alloc([null...], key_space)!;

	// Sequential inserts with immediate verification
	for (let i = 0z; i < key_space; i += 1) {
		let vp: *opaque = (&vals[i]: *opaque);
		must_set(m, keys[i], vp);
		exp[i] = vp;

		match (must_get(m, keys[i])) {
		case let got: *opaque => assert(got == vp, "phase1: get != set");
		case void => abort("phase1: get void after set");
		};
	};

	// Forward read sweep (all should be present)
	for (let i = 0z; i < key_space; i += 1) {
		match (must_get(m, keys[i])) {
		case let got: *opaque =>
			let want = match (exp[i]) {
			case null => abort("phase2: expect null but found value");
			case let p: *opaque => yield p;
			};
			assert(got == want, "phase2: value mismatch");
		case void =>
			abort("phase2: get void but expect value");
		};
	};

	// Strided overwrites with immediate verification
	for (let step = 0z; step < key_space; step += 1) {
		let i = (step * 7z) % key_space;
		let new_ix = (i + 12345z) % key_space;
		let vp: *opaque = (&vals[new_ix]: *opaque);
		must_set(m, keys[i], vp);
		exp[i] = vp;

		match (must_get(m, keys[i])) {
		case let got: *opaque => assert(got == vp, "phase3: replace mismatch");
		case void => abort("phase3: get void after replace");
		};
	};

	// Sparse deletes, every 3rd key
	for (let i = 0z; i < key_space; i += 1) {
		if (i % 3z != 0z) continue;

		let want = exp[i];
		match (must_del(m, keys[i])) {
		case let ret: *opaque =>
			match (want) {
			case null => abort("phase4: del returned value but expect null");
			case let p: *opaque => assert(ret == p, "phase4: del value mismatch");
			};
			exp[i] = null;

			match (must_del(m, keys[i])) {
			case void => void;
			case *opaque => abort("phase4: second delete returned value");
			};
		case void =>
			match (want) {
			case null => void;
			case *opaque => abort("phase4: del void but expect value");
			};
		};
	};

	// Insert again every 6th key
	for (let i = 0z; i < key_space; i += 1) {
		if (i % 6z != 0z) continue;
		let vp: *opaque = (&vals[(i * 5z + 1z) % key_space]: *opaque);
		must_set(m, keys[i], vp);
		exp[i] = vp;
	};

	// Even indices read, odd indices write
	for (let i = 0z; i < key_space; i += 1) {
		if ((i & 1z) == 0z) {
			// Read check
			match (must_get(m, keys[i])) {
			case let got: *opaque =>
				match (exp[i]) {
				case null => abort("phase6: even get found value; expect null");
				case let p: *opaque => assert(got == p, "phase6: even mismatch");
				};
			case void =>
				match (exp[i]) {
				case null => void;
				case *opaque => abort("phase6: even get void; expect value");
				};
			};
		} else {
			// Write (overwrite or create)
			let vp: *opaque = (&vals[(i * 3z + 7z) % key_space]: *opaque);
			must_set(m, keys[i], vp);
			exp[i] = vp;
		};
	};

	// Reading in reverse order
	for (let r = key_space; r > 0z; r -= 1) {
		let i = r - 1z;
		match (must_get(m, keys[i])) {
		case let got: *opaque =>
			match (exp[i]) {
			case null => abort("phase7: get found value; expect null");
			case let p: *opaque => assert(got == p, "phase7: reverse mismatch");
			};
		case void =>
			match (exp[i]) {
			case null => void;
			case *opaque => abort("phase7: reverse get void; expect value");
			};
		};
	};

	// Clear in reverse order
	for (let r = key_space; r > 0z; r -= 1) {
		let i = r - 1z;
		match (must_del(m, keys[i])) {
		case let ret: *opaque =>
			match (exp[i]) {
			case null => abort("phase8: del returned value; expect null");
			case let p: *opaque => assert(ret == p, "phase8: final del mismatch");
			};
			exp[i] = null;
		case void =>
			match (exp[i]) {
			case null => void;
			case *opaque => abort("phase8: del void; expect value");
			};
		};
	};

	// Read sweep ensure empty
	for (let i = 0z; i < key_space; i += 1) {
		match (must_get(m, keys[i])) {
		case void => void;
		case *opaque => abort("final: get returned value after full clear");
		};
		match (must_del(m, keys[i])) {
		case void => void;
		case *opaque => abort("final: del returned value after full clear");
		};
	};
};
