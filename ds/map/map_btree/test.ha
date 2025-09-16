use errors;
use strings;
use ds::map;

@test fn roundtrip() void = {
	let m: *map = match (new(2)) {
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
