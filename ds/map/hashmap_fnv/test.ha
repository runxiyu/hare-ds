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
	const buckets: [_]size = [64z, 128z];
	const makers: [_]*fn() (*map::map | nomem) = [&mk_slice_basic];

	for (let bi = 0z; bi < len(buckets); bi += 1) {
		for (let mi = 0z; mi < len(makers); mi += 1) {
			let m: *map = match (new(makers[mi], buckets[bi])) {
			case let p: *map => yield p;
			case errors::invalid => abort("fnv: invalid");
			case nomem => abort("fnv: nomem");
			};
			defer finish(m);
			map::stress_test(m, 20000);
		};
	};
};
