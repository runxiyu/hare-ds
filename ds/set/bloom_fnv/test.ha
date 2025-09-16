use ds::set;
use errors;

fn put_le64(dst: *[8]u8, v: u64) []u8 = {
	for (let i = 0z; i < 8z; i += 1) {
		dst[i] = ((v >> (8u64 * (i: u64))) & 0xFFu64): u8;
	};
	return dst[..];
};

@test fn invalid() void = {
	match (new(0, 1)) {
	case errors::invalid => void;
	case *set => abort("bloom_fnv: accepted m=0");
	case nomem => abort("bloom_fnv: nomem for m=0");
	};
	match (new(64, 0)) {
	case errors::invalid => void;
	case *set => abort("bloom_fnv: accepted k=0");
	case nomem => abort("bloom_fnv: nomem for k=0");
	};
};

@test fn test() void = {
	const ms: [2]size = [256z, 512z];
	const ks: [2]size = [2z, 3z];
	let buf: [8]u8 = [0...];
	const inserted: [4]u64 = [1u64, 5u64, 21u64, 45u64];
	const missing: [3]u64 = [2u64, 7u64, 88u64];

	for (let mi = 0z; mi < len(ms); mi += 1) {
		for (let ki = 0z; ki < len(ks); ki += 1) {
			let s = match (new(ms[mi], ks[ki])) {
			case let sp: *set => yield sp;
			case errors::invalid => abort("bloom_fnv: invalid parameters");
			case nomem => abort("bloom_fnv: nomem");
			};
			defer finish(s);
			let iface: *set::set = (s: *set::set);

			for (let i = 0z; i < len(inserted); i += 1) {
				let key = put_le64(&buf, inserted[i]);
				match (set::add(iface, key)) {
				case void => void;
				case nomem => abort("bloom_fnv: add nomem");
				};
				assert(set::contains(iface, key), "bloom_fnv: contains after add");
			};

			for (let i = 0z; i < len(missing); i += 1) {
				let key = put_le64(&buf, missing[i]);
				assert(!set::contains(iface, key), "bloom_fnv: false positive");
			};
		};
	};
};
