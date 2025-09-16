// SPDX-License-Identifier: MPL-2.0

use bytes;

// Deletes an item from a [[map]]. Returns the removed value or void.
export fn del(m: *map, key: []u8) (*opaque | void) = {
	for (let i = 0z; i < len(m.items); i += 1) {
		if (bytes::equal(m.items[i].0, key)) {
			let v = m.items[i].1;
			delete(m.items[i]);
			return v;
		};
	};
};
