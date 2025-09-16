use bytes;

fn keycmp(a: []u8, b: []u8) int = {
	let n = if (len(a) < len(b)) len(a) else len(b);
	for (let i = 0z; i < n; i += 1) {
		if (a[i] < b[i]) return -1;
		if (a[i] > b[i]) return 1;
	};
	if (len(a) < len(b)) return -1;
	if (len(a) > len(b)) return 1;
	return 0;
};

fn is_red(p: nullable *node) bool = {
	match (p) {
	case null => return false;
	case let n: *node => return n.color == color::RED;
	};
};

fn is_black(p: nullable *node) bool = !is_red(p);

fn set_color(p: nullable *node, c: color) void = {
	match (p) {
	case null => return;
	case let n: *node => n.color = c;
	};
};

fn set_parent(ch: nullable *node, pa: nullable *node) void = {
	match (ch) {
	case null => return;
	case let n: *node => n.parent = pa;
	};
};

fn subtree_min(n: *node) *node = {
	let cur = n;
	for (true) {
		match (cur.left) {
		case null => return cur;
		case let l: *node => cur = l;
		};
	};
};

fn transplant(m: *map, u: *node, v: nullable *node) void = {
	match (u.parent) {
	case null =>
		m.root = v;
	case let p: *node =>
		if (p.left == (u: nullable *node)) {
			p.left = v;
		} else {
			p.right = v;
		};
	};
	set_parent(v, u.parent);
};

fn rotate_left(m: *map, x: *node) void = {
	let y = match (x.right) {
	case let r: *node => yield r;
	case null => abort("rb invariant violated: rotate_left with null right");
	};

	x.right = y.left;
	set_parent(x.right, x);

	y.parent = x.parent;
	match (x.parent) {
	case null =>
		m.root = y;
	case let p: *node =>
		if (p.left == (x: nullable *node)) {
			p.left = y;
		} else {
			p.right = y;
		};
	};

	y.left = x;
	x.parent = y;
};

fn rotate_right(m: *map, x: *node) void = {
	let y = match (x.left) {
	case let l: *node => yield l;
	case null => abort("rb invariant violated: rotate_right with null left");
	};

	x.left = y.right;
	set_parent(x.left, x);

	y.parent = x.parent;
	match (x.parent) {
	case null =>
		m.root = y;
	case let p: *node =>
		if (p.left == (x: nullable *node)) {
			p.left = y;
		} else {
			p.right = y;
		};
	};

	y.right = x;
	x.parent = y;
};

fn insert_fixup(m: *map, z: *node) void = {
	let cur = z;
	for (true) {
		let p = match (cur.parent) {
		case null => break;
		case let pp: *node => yield pp;
		};
		if (p.color == color::BLACK) break;

		let gp = match (p.parent) {
		case null => break;
		case let g: *node => yield g;
		};

		let uncle: nullable *node = if (gp.left == (p: nullable *node))
			gp.right else gp.left;

		if (is_red(uncle)) {
			set_color(p, color::BLACK);
			set_color(uncle, color::BLACK);
			set_color(gp, color::RED);
			cur = gp;
			continue;
		};

		if (gp.left == (p: nullable *node)) {
			if (p.right == (cur: nullable *node)) {
				rotate_left(m, p);
				cur = p;
			};
			let p2 = match (cur.parent) {
			case null => break;
			case let pp2: *node => yield pp2;
			};
			let g2 = match (p2.parent) {
			case null => break;
			case let gg2: *node => yield gg2;
			};
			set_color(p2, color::BLACK);
			set_color(g2, color::RED);
			rotate_right(m, g2);
		} else {
			if (p.left == (cur: nullable *node)) {
				rotate_right(m, p);
				cur = p;
			};
			let p2 = match (cur.parent) {
			case null => break;
			case let pp2: *node => yield pp2;
			};
			let g2 = match (p2.parent) {
			case null => break;
			case let gg2: *node => yield gg2;
			};
			set_color(p2, color::BLACK);
			set_color(g2, color::RED);
			rotate_left(m, g2);
		};
	};
	match (m.root) {
	case null => void;
	case let r: *node => r.color = color::BLACK;
	};
};

fn find_node(m: *map, key: []u8) nullable *node = {
	let cur = m.root;
	for (true) {
		match (cur) {
		case null => return null;
		case let n: *node =>
			let c = keycmp(key, n.key);
			if (c == 0) return n;
			cur = if (c < 0) n.left else n.right;
		};
	};
};

fn delete_fixup(m: *map, x0: nullable *node, p0: nullable *node) void = {
	let x = x0;
	let p = p0;

	for (x != m.root && is_black(x)) {
		let pp = match (p) {
		case null => break;
		case let q: *node => yield q;
		};

		if (pp.left == x) {
			let mutw = pp.right;
			let w = match (mutw) {
			case null => break;
			case let w_: *node => yield w_;
			};
			if (is_red(w)) {
				set_color(w, color::BLACK);
				set_color(pp, color::RED);
				rotate_left(m, pp);
				mutw = pp.right;
			};
			let wr = match (mutw) {
			case null => yield null;
			case let w2: *node => yield w2.right;
			};
			let wl = match (mutw) {
			case null => yield null;
			case let w2: *node => yield w2.left;
			};
			if (is_black(wl) && is_black(wr)) {
				set_color(mutw, color::RED);
				x = pp;
				p = pp.parent;
			} else {
				if (is_black(wr)) {
					set_color(wl, color::BLACK);
					set_color(mutw, color::RED);
					match (mutw) {
					case null => void;
					case let ww: *node => rotate_right(m, ww);
					};
					mutw = pp.right;
				};
				match (mutw) {
				case null => void;
				case let w3: *node =>
					w3.color = pp.color;
					set_color(pp, color::BLACK);
					set_color(w3.right, color::BLACK);
					rotate_left(m, pp);
				};
				x = m.root;
				p = null;
			};
		} else {
			let mutw = pp.left;
			let w = match (mutw) {
			case null => break;
			case let w_: *node => yield w_;
			};
			if (is_red(w)) {
				set_color(w, color::BLACK);
				set_color(pp, color::RED);
				rotate_right(m, pp);
				mutw = pp.left;
			};
			let wl = match (mutw) {
			case null => yield null;
			case let w2: *node => yield w2.left;
			};
			let wr = match (mutw) {
			case null => yield null;
			case let w2: *node => yield w2.right;
			};
			if (is_black(wl) && is_black(wr)) {
				set_color(mutw, color::RED);
				x = pp;
				p = pp.parent;
			} else {
				if (is_black(wl)) {
					set_color(wr, color::BLACK);
					set_color(mutw, color::RED);
					match (mutw) {
					case null => void;
					case let ww: *node => rotate_left(m, ww);
					};
					mutw = pp.left;
				};
				match (mutw) {
				case null => void;
				case let w3: *node =>
					w3.color = pp.color;
					set_color(pp, color::BLACK);
					set_color(w3.left, color::BLACK);
					rotate_right(m, pp);
				};
				x = m.root;
				p = null;
			};
		};
	};
	set_color(x, color::BLACK);
};
