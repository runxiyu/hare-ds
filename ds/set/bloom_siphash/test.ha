use crypto::random;
use ds::set;
use errors;

fn put_le64(dst: *[8]u8, v: u64) []u8 = {
	for (let i = 0z; i < 8z; i += 1) {
		dst[i] = ((v >> (8u64 * (i: u64))) & 0xFFu64): u8;
	};
	return dst[..];
};

@test fn invalid() void = {
	let key: [16]u8 = [0...];
	match (new(0, 1, key)) {
	case errors::invalid => void;
	case *set => abort("bloom_siphash: accepted m=0");
	case nomem => abort("bloom_siphash: nomem for m=0");
	};
	match (new(64, 0, key)) {
	case errors::invalid => void;
	case *set => abort("bloom_siphash: accepted k=0");
	case nomem => abort("bloom_siphash: nomem for k=0");
	};
};

@test fn test() void = {
	let key1: [16]u8 = [0...];
	let key2: [16]u8 = [0...];
	random::buffer(&key1);
	random::buffer(&key2);
	const keys: [2]*[16]u8 = [&key1, &key2];
	const ms: [2]size = [256z, 512z];
	const ks: [2]size = [2z, 3z];

	let buf: [8]u8 = [0...];
	const inserted: [4]u64 = [4u64, 12u64, 30u64, 102u64];
	const missing: [3]u64 = [3u64, 7u64, 55u64];

	for (let mi = 0z; mi < len(ms); mi += 1) {
		for (let ki = 0z; ki < len(ks); ki += 1) {
			for (let keyi = 0z; keyi < len(keys); keyi += 1) {
				let s = match (new(ms[mi], ks[ki], *keys[keyi])) {
				case let sp: *set => yield sp;
				case errors::invalid => abort("bloom_siphash: invalid parameters");
				case nomem => abort("bloom_siphash: nomem");
				};
				defer finish(s);
				let iface: *set::set = (s: *set::set);

				for (let i = 0z; i < len(inserted); i += 1) {
					let key = put_le64(&buf, inserted[i]);
					match (set::add(iface, key)) {
					case void => void;
					case nomem => abort("bloom_siphash: add nomem");
					};
					assert(set::contains(iface, key), "bloom_siphash: contains after add");
				};

				for (let i = 0z; i < len(missing); i += 1) {
					let key = put_le64(&buf, missing[i]);
					// False positives are fine it's a bloom filter
				};
			};
		};
	};
};
