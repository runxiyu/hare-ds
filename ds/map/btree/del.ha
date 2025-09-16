// SPDX-License-Identifier: MPL-2.0

use bytes;
use sort;

// Deletes an item from a [[map]]. Returns the removed value or void.
export fn del(m: *map, key: []u8) (*opaque | void) = {
	const r = delete_rec(m, m.root, key);
	if (len(m.root.keys) == 0 && !m.root.leaf) {
		m.root = m.root.children[0];
	};
	return r;
};

