use crypto::random;
use ds::map;
use ds::map::slice_basic;
use ds::map::slice_sorted;
use ds::map::btree;
use ds::map::rbtree;
use ds::map::swiss_siphash;
use errors;

fn mk_slice_basic() (*map::map | nomem) = {
	match (slice_basic::new()) {
	case let p: *slice_basic::map => return (p: *map::map);
	case nomem => return nomem;
	};
};

@test fn test() void = {
	const buckets: [_]size = [128z, 256z];
	const makers: [_]*fn() (*map::map | nomem) = [&mk_slice_basic];

	let key1: [16]u8 = [0...];
	let key2: [16]u8 = [0...];
	random::buffer(&key1);
	random::buffer(&key2);
	const keys: [2]*[16]u8 = [&key1, &key2];

	for (let bi = 0z; bi < len(buckets); bi += 1) {
		for (let ki = 0z; ki < len(keys); ki += 1) {
			for (let mi = 0z; mi < len(makers); mi += 1) {
				let m: *map = match (new(makers[mi], buckets[bi], *keys[ki])) {
				case let p: *map => yield p;
				case errors::invalid => abort("siphash: invalid");
				case nomem => abort("siphash: nomem");
				};
				defer finish(m);
				map::stress_test(m, 20000);
			};
		};
	};
};
