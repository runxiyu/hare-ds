// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2024 Drew DeVault <drew@ddevault.org>
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use bytes;
use hash;
use hash::siphash;
use ds::map;

// Deletes an item from a [[map]].
export fn del(m: *map, key: []u8) (*opaque | void) = {
	let h = siphash::siphash(2, 4, &m.siphash_key);
	defer hash::close(&h);
	hash::write(&h, key);
	let b = m.buckets[siphash::sum(&h): size % m.n];
	return map::del(b, key);
};
