// SPDX-License-Identifier: MPL-2.0

use bytes;
use sort;

// Sets an item in a [[map]], replacing any existing item with the same key.
export fn set(m: *map, key: []u8, value: *opaque) (void | nomem) = {
	if (len(m.root.keys) == 2 * m.t - 1) {
		let s = node_new(m.t, false)?;
		append(s.children, m.root)?;
		m.root = s;
		split_child(m, s, 0)?;
	};
	insert_nonfull(m, m.root, key, value)?;
};
