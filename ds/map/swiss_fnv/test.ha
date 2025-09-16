use ds::map;
use errors;

@test fn test() void = {
	const groups: [2]size = [1z, 32z];

	for (let gi = 0z; gi < len(groups); gi += 1) {
		let m: *map = match (new(groups[gi])) {
		case let p: *map => yield p;
		case errors::invalid => abort("swiss_fnv: invalid groups");
		case nomem => abort("swiss_fnv: nomem");
		};
		defer finish(m);
		map::stress_test(m, 200000);
	};
};
