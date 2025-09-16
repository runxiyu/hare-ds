use crypto::random;
use ds::map;
use ds::map::slice_basic;
use ds::map::slice_sorted;
use ds::map::btree;
use ds::map::rbtree;
use ds::map::swiss_siphash;
use errors;
use hash;
use hash::fnv;
use hash::siphash;

fn test_fnv64(_params: nullable *opaque, key: []u8) size = {
	let h = fnv::fnv64a();
	hash::write(&h, key);
	return fnv::sum64(&h): size;
};

fn test_siphash64(params: nullable *opaque, key: []u8) size = {
	let k = match (params) {
	case null => abort("siphash test hash: missing key");
	case let p: *opaque => yield (p: *[16]u8);
	};
	let h = siphash::siphash(2, 4, k);
	defer hash::close(&h);
	hash::write(&h, key);
	return siphash::sum(&h): size;
};

fn mk_slice_basic() (*map::map | nomem) = {
	match (slice_basic::new()) {
	case let p: *slice_basic::map => return (p: *map::map);
	case nomem => return nomem;
	};
};
fn mk_slice_sorted() (*map::map | nomem) = {
	match (slice_sorted::new()) {
	case let p: *slice_sorted::map => return (p: *map::map);
	case nomem => return nomem;
	};
};
fn mk_btree2() (*map::map | nomem) = {
	match (btree::new(2)) {
	case let p: *btree::map => return (p: *map::map);
	case errors::invalid => abort("btree(2) invalid");
	case nomem => return nomem;
	};
};
fn mk_rbtree() (*map::map | nomem) = {
	match (rbtree::new()) {
	case let p: *rbtree::map => return (p: *map::map);
	case nomem => return nomem;
	};
};
fn mk_swiss() (*map::map | nomem) = {
	let key: [16]u8 = [0...];
	random::buffer(&key);
	match (swiss_siphash::new(1, key)) {
	case let p: *swiss_siphash::map => return (p: *map::map);
	case errors::invalid => abort("swiss: invalid");
	case nomem => return nomem;
	};
};

@test fn test() void = {
	const buckets: [2]size = [128z, 256z];
	const makers: [5]*fn() (*map::map | nomem) = [&mk_slice_basic, &mk_slice_sorted, &mk_btree2, &mk_rbtree, &mk_swiss];

	let skey1: [16]u8 = [0...];
	let skey2: [16]u8 = [0...];
	random::buffer(&skey1);
	random::buffer(&skey2);
	const hf: [2]*fn(hash_params: nullable *opaque, key: []u8) size =
		[&test_fnv64, &test_siphash64];
	const hp: [2]nullable *opaque = [null, (&skey1: *opaque)];

	for (let bi = 0z; bi < len(buckets); bi += 1) {
		for (let hi = 0z; hi < len(hf); hi += 1) {
			for (let mi = 0z; mi < len(makers); mi += 1) {
				let m: *map = match (new(makers[mi], buckets[bi], hf[hi], hp[hi])) {
				case let p: *map => yield p;
				case errors::invalid => abort("hashmap: invalid");
				case nomem => abort("hashmap: nomem");
				};
				defer finish(m);
				map::stress_test(m, 20000);
			};
		};
	};
};
