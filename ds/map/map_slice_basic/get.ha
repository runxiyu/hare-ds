// SPDX-License-Identifier: MPL-2.0

use bytes;

// Gets an item from a [[map]] by key, returning void if not found.
export fn get(m: *map, key: []u8) (*opaque | void) = {
	for (let i = 0z; i < len(m.items); i += 1) {
		if (bytes::equal(m.items[i].0, key)) {
			return m.items[i].1;
		};
	};
};
