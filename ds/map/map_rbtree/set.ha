use bytes;

export fn set(m: *map, key: []u8, value: *opaque) (void | nomem) = {
	match (find_node(m, key)) {
	case let ex: *node =>
		ex.val = value;
		return;
	case null => void;
	};

	let z = alloc(node {
		color = color::RED,
		key = key,
		val = value,
		left = null,
		right = null,
		parent = null,
	})?;

	let y: nullable *node = null;
	let x = m.root;

	for (true) {
		match (x) {
		case null => break;
		case let xn: *node =>
			y = xn;
			if (keycmp(z.key, xn.key) < 0) {
				x = xn.left;
			} else {
				x = xn.right;
			};
		};
	};

	z.parent = y;
	match (y) {
	case null =>
		m.root = z;
	case let yn: *node =>
		if (keycmp(z.key, yn.key) < 0) {
			yn.left = z;
		} else {
			yn.right = z;
		};
	};

	insert_fixup(m, z);
};
