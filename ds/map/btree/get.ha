// SPDX-License-Identifier: MPL-2.0

use bytes;
use sort;

// Gets an item from a [[map]] by key, returning void if not found.
export fn get(m: *map, key: []u8) (*opaque | void) = {
	let x = m.root;
	for (true) {
		let i = sort::lbisect((x.keys: []const opaque), size([]u8), (&key: const *opaque), &cmp_u8slice);
		if (i < len(x.keys) && bytes::equal(x.keys[i], key)) {
			return x.vals[i];
		};
		if (x.leaf) {
			return;
		};
		x = x.children[i];
	};
};
