use crypto::random;
use errors;
use strings;
use ds::map;
use ds::map::map_slice_basic;
use ds::map::map_slice_sorted;
use ds::map::map_btree;
use ds::map::map_rbtree;

fn mk_slice_basic() (*map::map | nomem) = {
	match (map_slice_basic::new()) {
	case let p: *map_slice_basic::map => return (p: *map::map);
	case nomem => return nomem;
	};
};

fn mk_slice_sorted() (*map::map | nomem) = {
	match (map_slice_sorted::new()) {
	case let p: *map_slice_sorted::map => return (p: *map::map);
	case nomem => return nomem;
	};
};

fn mk_btree() (*map::map | nomem) = {
	match (map_btree::new(2)) {
	case let p: *map_btree::map => return (p: *map::map);
	case errors::invalid => abort("map_btree::new(2) invalid (unexpected)");
	case nomem => return nomem;
	};
};

fn mk_rbtree() (*map::map | nomem) = {
	match (map_rbtree::new()) {
	case let p: *map_rbtree::map => return (p: *map::map);
	case nomem => return nomem;
	};
};

fn run_case(make_fallback: *fn() (*map::map | nomem)) void = {
	const key: [16]u8 = [0...];
	random::buffer(&key);

	let m: *map = match (new(make_fallback, 16, key)) {
	case let p: *map => yield p;
	case errors::invalid => abort("unexpected errors::invalid");
	case nomem => abort("unexpected nomem");
	};
	defer finish(m);

	let v1 = 1, v2 = 2, v3 = 3;
	let p1: *opaque = (&v1: *opaque);
	let p2: *opaque = (&v2: *opaque);
	let p3: *opaque = (&v3: *opaque);

	let k1 = strings::toutf8("alpha");
	let k2 = strings::toutf8("beta");
	let k3 = strings::toutf8("gamma");

	match (map::set(m, k1, p1)) {
	case void => yield;
	case nomem => abort("unexpected nomem in set(k1,p1)");
	};

	match (map::get(m, k1)) {
	case let got: *opaque =>
		assert(got == p1, "get(k1) must return p1");
	case void =>
		abort("get(k1) unexpectedly void");
	};

	match (map::set(m, k1, p2)) {
	case void => yield;
	case nomem => abort("unexpected nomem in replace");
	};
	match (map::get(m, k1)) {
	case let got: *opaque =>
		assert(got == p2, "replace must overwrite prior value");
	case void =>
		abort("get(k1) void after replace");
	};

	match (map::set(m, k2, p3)) {
	case void => yield;
	case nomem => abort("unexpected nomem in set(k2,p3)");
	};

	match (map::get(m, k3)) {
	case void => yield;
	case *opaque =>
		abort("get(k3) must be void for missing key");
	};

	match (map::del(m, k2)) {
	case let got: *opaque =>
		assert(got == p3, "del(k2) must return stored value");
	case void =>
		abort("del(k2) unexpectedly void");
	};
	match (map::del(m, k2)) {
	case void => yield;
	case *opaque =>
		abort("del(k2) must be void after prior delete");
	};
};

@test fn roundtrip_with_slice_basic() void = {
	run_case(&mk_slice_basic);
};

@test fn roundtrip_with_slice_sorted() void = {
	run_case(&mk_slice_sorted);
};

@test fn roundtrip_with_btree() void = {
	run_case(&mk_btree);
};

@test fn roundtrip_with_rbtree() void = {
	run_case(&mk_rbtree);
};
