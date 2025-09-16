use crypto::random;
use ds::map;
use ds::map::slice_basic;
use ds::map::slice_sorted;
use ds::map::btree;
use ds::map::rbtree;
use ds::map::swiss_siphash;
use errors;

fn testhash(_params: nullable *opaque, key: []u8) size = {
	let val: u64 = 0;
	let limit = if (len(key) < 8z) len(key) else 8z;
	for (let i = 0z; i < limit; i += 1) {
		val |= (key[i]: u64) << (8u64 * (i: u64));
	};
	return (val: size);
};

fn mk_slice_basic() (*map::map | nomem) = {
	match (slice_basic::new()) {
	case let p: *slice_basic::map => return (p: *map::map);
	case nomem => return nomem;
	};
};

@test fn invalid() void = {
	match (new(&mk_slice_basic, 0, &testhash, null)) {
	case errors::invalid => void;
	case *map => abort("hashmap: accepted n=0");
	case nomem => abort("hashmap: nomem for n=0");
	};
};

@test fn test() void = {
	const buckets: [_]size = [64z, 128z];
	const makers: [_]*fn() (*map::map | nomem) = [&mk_slice_basic];

	for (let bi = 0z; bi < len(buckets); bi += 1) {
		for (let mi = 0z; mi < len(makers); mi += 1) {
			let m = match (new(makers[mi], buckets[bi], &testhash, null)) {
			case let p: *map => yield p;
			case errors::invalid => abort("hashmap: invalid parameters");
			case nomem => abort("hashmap: nomem");
			};
			defer finish(m);
			map::stress_test(m, 20000);
		};
	};
};
