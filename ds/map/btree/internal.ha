// SPDX-License-Identifier: MPL-2.0

use bytes;
use sort;

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

fn cmp_u8slice(a: const *opaque, b: const *opaque) int = {
	let sa = *(a: *[]u8);
	let sb = *(b: *[]u8);
	return keycmp(sa, sb);
};

fn node_new(t: size, leaf: bool) (*node | nomem) = {
	let capk = 2 * t - 1;
	let capc = if (leaf) 0z else 2z * t;

	let empty_keys: [][]u8 = [];
	let keys = alloc(empty_keys, capk)?;

	let empty_vals: []*opaque = [];
	let vals = alloc(empty_vals, capk)?;

	let children: []*node = if (leaf) {
		yield [];
	} else {
		let empty_children: []*node = [];
		yield alloc(empty_children, capc)?;
	};

	let nd = alloc(node {
		leaf = leaf,
		keys = keys,
		vals = vals,
		children = children,
	})?;
	return nd;
};

fn split_child(m: *map, x: *node, i: size) (void | nomem) = {
	const t = m.t;
	let y = x.children[i];
	let z = node_new(t, y.leaf)?;

	let medk = y.keys[t - 1];
	let medv = y.vals[t - 1];

	append(z.keys, y.keys[t..]...)?;
	append(z.vals, y.vals[t..]...)?;
	if (!y.leaf) {
		append(z.children, y.children[t..]...)?;
	};

	y.keys = y.keys[..t - 1];
	y.vals = y.vals[..t - 1];
	if (!y.leaf) {
		y.children = y.children[..t];
	};

	insert(x.keys[i], medk)?;
	insert(x.vals[i], medv)?;
	insert(x.children[i + 1], z)?;
};

fn insert_nonfull(m: *map, x: *node, key: []u8, val: *opaque) (void | nomem) = {
	let i = sort::lbisect((x.keys: []const opaque), size([]u8),
		(&key: const *opaque), &cmp_u8slice);

	if (i < len(x.keys) && bytes::equal(x.keys[i], key)) {
		x.vals[i] = val;
		return;
	};

	if (x.leaf) {
		insert(x.keys[i], key)?;
		insert(x.vals[i], val)?;
		return;
	};

	if (len(x.children[i].keys) == 2 * m.t - 1) {
		split_child(m, x, i)?;
		let cmp = cmp_u8slice((&key: const *opaque),
			(&x.keys[i]: const *opaque));
		if (cmp == 0) {
			x.vals[i] = val;
			return;
		};
		if (cmp > 0) {
			i += 1;
		};
	};
	insert_nonfull(m, x.children[i], key, val)?;
};

fn merge_children(m: *map, x: *node, i: size) void = {
	let left = x.children[i];
	let right = x.children[i + 1];

	insert(left.keys[len(left.keys)], x.keys[i])!;
	insert(left.vals[len(left.vals)], x.vals[i])!;

	append(left.keys, right.keys...)!;
	append(left.vals, right.vals...)!;
	if (!left.leaf) {
		append(left.children, right.children...)!;
	};

	delete(x.keys[i]);
	delete(x.vals[i]);
	delete(x.children[i + 1]);
};

fn ensure_child_has_space(m: *map, x: *node, i: size) void = {
	const t = m.t;
	let c = x.children[i];

	if (len(c.keys) >= t) return;

	if (i > 0 && len(x.children[i - 1].keys) >= t) {
		let ls = x.children[i - 1];

		insert(c.keys[0], x.keys[i - 1])!;
		insert(c.vals[0], x.vals[i - 1])!;

		if (!c.leaf) {
			let moved = ls.children[len(ls.children) - 1];
			insert(c.children[0], moved)!;
			delete(ls.children[len(ls.children) - 1]);
		};

		x.keys[i - 1] = ls.keys[len(ls.keys) - 1];
		x.vals[i - 1] = ls.vals[len(ls.vals) - 1];
		delete(ls.keys[len(ls.keys) - 1]);
		delete(ls.vals[len(ls.vals) - 1]);
		return;
	};

	if (i + 1 < len(x.children) && len(x.children[i + 1].keys) >= t) {
		let rs = x.children[i + 1];

		insert(c.keys[len(c.keys)], x.keys[i])!;
		insert(c.vals[len(c.vals)], x.vals[i])!;

		if (!c.leaf) {
			let moved = rs.children[0];
			insert(c.children[len(c.children)], moved)!;
			delete(rs.children[0]);
		};

		x.keys[i] = rs.keys[0];
		x.vals[i] = rs.vals[0];
		delete(rs.keys[0]);
		delete(rs.vals[0]);
		return;
	};

	if (i + 1 < len(x.children)) {
		merge_children(m, x, i);
	} else {
		merge_children(m, x, i - 1);
	};
};

fn pop_max(m: *map, x: *node) ([]u8, *opaque) = {
	let cur = x;
	for (!cur.leaf) {
		let last_before = len(cur.children) - 1;
		ensure_child_has_space(m, cur, last_before);
		let last = len(cur.children) - 1;
		cur = cur.children[last];
	};
	let k = cur.keys[len(cur.keys) - 1];
	let v = cur.vals[len(cur.vals) - 1];
	delete(cur.keys[len(cur.keys) - 1]);
	delete(cur.vals[len(cur.vals) - 1]);
	return (k, v);
};

fn pop_min(m: *map, x: *node) ([]u8, *opaque) = {
	let cur = x;
	for (!cur.leaf) {
		ensure_child_has_space(m, cur, 0);
		cur = cur.children[0];
	};
	let k = cur.keys[0];
	let v = cur.vals[0];
	delete(cur.keys[0]);
	delete(cur.vals[0]);
	return (k, v);
};

fn delete_rec(m: *map, x: *node, key: []u8) (*opaque | void) = {
	let i = sort::lbisect((x.keys: []const opaque), size([]u8),
		(&key: const *opaque), &cmp_u8slice);

	if (i < len(x.keys) && bytes::equal(x.keys[i], key)) {
		if (x.leaf) {
			let ret = x.vals[i];
			delete(x.keys[i]);
			delete(x.vals[i]);
			return ret;
		};

		const t = m.t;
		let y = x.children[i];
		let z = x.children[i + 1];

		if (len(y.keys) >= t) {
			let (pk, pv) = pop_max(m, y);
			let ret = x.vals[i];
			x.keys[i] = pk;
			x.vals[i] = pv;
			return ret;
		} else if (len(z.keys) >= t) {
			let (sk, sv) = pop_min(m, z);
			let ret = x.vals[i];
			x.keys[i] = sk;
			x.vals[i] = sv;
			return ret;
		} else {
			merge_children(m, x, i);
			return delete_rec(m, y, key);
		};
	};

	if (x.leaf) {
		return;
	};

	ensure_child_has_space(m, x, i);
	if (i >= len(x.children)) {
		i = len(x.children) - 1;
	};
	return delete_rec(m, x.children[i], key);
};
