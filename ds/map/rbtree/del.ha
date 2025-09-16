// Deletes an item from a [[map]]. Returns the removed value or void.
export fn del(m: *map, key: []u8) (*opaque | void) = {
	let z = find_node(m, key);
	match (z) {
	case null => return;
	case let nodez: *node =>
		let ret = nodez.val;

		let y = nodez;
		let y_orig = y.color;

		let x: nullable *node = null;
		let p_for_fix: nullable *node = null;

		if (nodez.left == null) {
			x = nodez.right;
			p_for_fix = nodez.parent;
			transplant(m, nodez, nodez.right);
		} else if (nodez.right == null) {
			x = nodez.left;
			p_for_fix = nodez.parent;
			transplant(m, nodez, nodez.left);
		} else {
			let r = match (nodez.right) {
			case let rr: *node => yield rr;
			case null => abort("rb invariant violated: del: right is null");
			};
			let s = subtree_min(r);
			y = s;
			let yor = y.color;
			y_orig = yor;

			x = y.right;
			if (y.parent == (nodez: nullable *node)) {
				p_for_fix = y;
				set_parent(x, y);
			} else {
				p_for_fix = y.parent;
				transplant(m, y, y.right);
				y.right = nodez.right;
				set_parent(y.right, y);
			};

			transplant(m, nodez, y);
			y.left = nodez.left;
			set_parent(y.left, y);
			y.color = nodez.color;
		};

		free(nodez);

		if (y_orig == color::BLACK) {
			delete_fixup(m, x, p_for_fix);
		};

		return ret;
	};
};
