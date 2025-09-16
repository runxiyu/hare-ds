use crypto::random;
use ds::map;
use errors;

@test fn test() void = {
	let key1: [16]u8 = [0...];
	let key2: [16]u8 = [0...];
	random::buffer(&key1);
	random::buffer(&key2);

	const groups: [2]size = [1z, 32z];
	const keys: [2]*[16]u8 = [&key1, &key2];

	for (let gi = 0z; gi < len(groups); gi += 1) {
		for (let ki = 0z; ki < len(keys); ki += 1) {
			let m: *map = match (new(groups[gi], *keys[ki])) {
			case let p: *map => yield p;
			case errors::invalid => abort("swiss_siphash: invalid groups");
			case nomem => abort("swiss_siphash: nomem");
			};
			defer finish(m);
			map::stress_test(m, 20000);
		};
	};
};
