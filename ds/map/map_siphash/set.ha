// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2024 Drew DeVault <drew@ddevault.org>
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use bytes;
use hash;
use hash::siphash;
use ds::map;

// Sets an item in a [[map]], replacing any existing item with the same key.
export fn set(m: *map, key: []u8, value: *opaque) (void | nomem) = {
	let h = siphash::siphash(2, 4, &m.siphash_key);
	defer hash::close(&h);
	hash::write(&h, key);
	let b = m.buckets[siphash::sum(&h): size % m.n];
	return map::set(b, key, value);
};
