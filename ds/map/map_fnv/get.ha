// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2024 Drew DeVault <drew@ddevault.org>
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use hash;
use hash::fnv;
use ds::map;

// Gets an item from a [[map]] by key, returning void if not found.
export fn get(m: *map, key: []u8) (*opaque | void) = {
	let h = fnv::fnv64a();
	hash::write(&h, key);
	let b = m.buckets[fnv::sum64(&h): size % m.n];
	return map::get(b, key);
};
