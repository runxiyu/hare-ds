// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2024 Drew DeVault <drew@ddevault.org>
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use bytes;
use hash;
use hash::fnv;

// Gets an item from a [[map]] by key, returning void if not found.
export fn get(m: *map, key: []u8) (*opaque | void) = {
	let hash = fnv::fnv64a();
	hash::write(&hash, key);
	let bucket = &m.buckets[fnv::sum64(&hash): size % m.n];
	for (let i = 0z; i < len(bucket); i += 1) {
		if (bytes::equal(bucket[i].0, key)) {
			return bucket[i].1;
		};
	};
};
