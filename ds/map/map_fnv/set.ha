// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2024 Drew DeVault <drew@ddevault.org>
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use hash;
use hash::fnv;
use ds::map;

// Sets an item in a [[map]], replacing any existing item with the same key.
export fn set(m: *map, key: []u8, value: *opaque) (void | nomem) = {
	let h = fnv::fnv64a();
	hash::write(&h, key);
	let b = m.buckets[fnv::sum64(&h): size % m.n];
	return map::set(b, key, value);
};
