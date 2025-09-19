use ds::map;
use errors;

@test fn test() void = {
	const ts: [_]size = [2z, 3z, 8z];
	for (let i = 0z; i < len(ts); i += 1) {
		let m: *map = match (new(ts[i])) {
		case let p: *map => yield p;
		case errors::invalid => abort("btree: invalid t");
		case nomem => abort("btree: nomem");
		};
		defer finish(m);
		map::stress_test(m, 20000);
	};
};
