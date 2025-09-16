// SPDX-License-Identifier: MPL-2.0

use bytes;

// Sets an item in a [[map]], replacing any existing item with the same key.
export fn set(m: *map, key: []u8, value: *opaque) (void | nomem) = {
	for (let i = 0z; i < len(m.items); i += 1) {
		if (bytes::equal(m.items[i].0, key)) {
			m.items[i].1 = value;
			return;
		};
	};
	append(m.items, (key, value))?;
};
