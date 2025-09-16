// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2024 Drew DeVault <drew@ddevault.org>
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use bytes;
use hash;
use hash::siphash;

// Deletes an item from a [[map]].
export fn del(m: *map, key: []u8) (*opaque | void) = {
	let hash = siphash::siphash(2, 4, &m.siphash_key);
	defer hash::close(&hash);
	hash::write(&hash, key);
	let bucket = &m.buckets[siphash::sum(&hash): size % m.n];
	for (let i = 0z; i < len(bucket); i += 1) {
		if (bytes::equal(bucket[i].0, key)) {
			let item = bucket[i];
			delete(bucket[i]);
			return item.1;
		};
	};
};

