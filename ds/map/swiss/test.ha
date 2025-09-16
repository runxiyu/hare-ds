use ds::map;
use errors;

fn testhash(_params: nullable *opaque, key: []u8) size = {
	let val: u64 = 0;
	let limit = if (len(key) < 8z) len(key) else 8z;
	for (let i = 0z; i < limit; i += 1) {
		val |= (key[i]: u64) << (8u64 * (i: u64));
	};
	return (val: size);
};

@test fn invalid() void = {
	match (new(0, &testhash, null)) {
	case errors::invalid => void;
	case *map => abort("swiss: accepted n_groups=0");
	case nomem => abort("swiss: nomem for n_groups=0");
	};
};

@test fn test() void = {
	const groups: [3]size = [1z, 17z, 128z];

	for (let gi = 0z; gi < len(groups); gi += 1) {
		let m = match (new(groups[gi], &testhash, null)) {
		case let p: *map => yield p;
		case errors::invalid => abort("swiss: invalid parameters");
		case nomem => abort("swiss: nomem");
		};
		defer finish(m);
		map::stress_test(m, 20000);
	};
};
