use ds::set;
use errors;

fn testhash(_params: nullable *opaque, key: []u8) size = {
	let val: u64 = 0;
	let limit = if (len(key) < 8z) len(key) else 8z;
	for (let i = 0z; i < limit; i += 1) {
		val |= (key[i]: u64) << (8u64 * (i: u64));
	};
	return (val: size);
};

fn put_le64(dst: *[8]u8, v: u64) []u8 = {
	for (let i = 0z; i < 8z; i += 1) {
		dst[i] = ((v >> (8u64 * (i: u64))) & 0xFFu64): u8;
	};
	return dst[..];
};

@test fn invalid() void = {
	match (new(0, 1, &testhash, null)) {
	case errors::invalid => void;
	case *set => abort("new accepted m=0");
	case nomem => abort("new(m=0) returned nomem");
	};
	match (new(64, 0, &testhash, null)) {
	case errors::invalid => void;
	case *set => abort("new accepted k=0");
	case nomem => abort("new(k=0) returned nomem");
	};
};

@test fn basic() void = {
	let s = match (new(256, 2, &testhash, null)) {
	case let sp: *set => yield sp;
	case errors::invalid => abort("basic: invalid");
	case nomem => abort("basic: nomem");
	};
	defer finish(s);
	let iface: *set::set = (s: *set::set);

	const inserted: [4]u64 = [1u64, 3u64, 17u64, 41u64];
	let keybuf: [8]u8 = [0...];
	for (let i = 0z; i < len(inserted); i += 1) {
		let key = put_le64(&keybuf, inserted[i]);
		assert(!contains(s, key), "contains before add");
		match (set::add(iface, key)) {
		case void => void;
		case nomem => abort("basic: add nomem");
		};
		assert(set::contains(iface, key), "contains after add");
	};

	const missing: [3]u64 = [11u64, 21u64, 111u64];
	for (let i = 0z; i < len(missing); i += 1) {
		let key = put_le64(&keybuf, missing[i]);
		assert(!set::contains(iface, key), "contains false positive");
	};
};
