// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2024 Drew DeVault <drew@ddevault.org>
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use bytes;
use hash;
use hash::fnv;

// Sets an item in a [[map]], replacing any existing item with the same key.
export fn set(m: *map, key: []u8, value: *opaque) (void | nomem) = {
	let hash = fnv::fnv64a();
	hash::write(&hash, key);
	let bucket = &m.buckets[fnv::sum64(&hash): size % m.n];
	for (let i = 0z; i < len(bucket); i += 1) {
		if (bytes::equal(bucket[i].0, key)) {
			bucket[i].1 = value;
			return;
		};
	};
	append(bucket, (key, value))?;
};
