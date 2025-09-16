// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2024 Drew DeVault <drew@ddevault.org>
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use bytes;
use errors;
use hash;
use hash::siphash;

// Creates a new [[map]] with the given number of buckets and SipHash key.
export fn new(n: size, siphash_key: [16]u8) (*map | errors::invalid | nomem) = {
	if (n == 0) {
		return errors::invalid;
	};

	let empty_bucket: []([]u8, *opaque) = [];
	let buckets: [][]([]u8, *opaque) = alloc([empty_bucket...], n)?;

	let m = alloc(map {
		vt = &_vt,
		n = n,
		siphash_key = siphash_key,
		buckets = buckets,
	})?;

	return m;
};
