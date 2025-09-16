// SPDX-License-Identifier: MPL-2.0

use bytes;

// Gets an item from a [[map]] by key, returning void if not found.
export fn get(m: *map, key: []u8) (*opaque | void) = {
	let n = find_node(m, key);
	match (n) {
	case null => return;
	case let p: *node => return p.val;
	};
};
