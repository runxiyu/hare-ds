use ds::map;

@test fn test() void = {
	let m: *map = match (new()) {
	case let p: *map => yield p;
	case nomem => abort("slice_basic: nomem");
	};
	defer finish(m);
	map::stress_test(m, 2000);
};
