// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2024 Drew DeVault <drew@ddevault.org>
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use ds::map;

// Gets an item from a [[map]] by key, returning void if not found.
export fn get(m: *map, key: []u8) (*opaque | void) = {
	let b = m.buckets[hash64(m, key) % m.n];
	return map::get(b, key);
};
