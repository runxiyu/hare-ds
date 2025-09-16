// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2024 Drew DeVault <drew@ddevault.org>
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use bytes;
use errors;
use ds::map;

// Creates a new [[map]] with a function that creates fallback maps, the number
// of buckets, and the hash function and parameters.
export fn new(
	make_fallback: *fn() (*map::map | nomem),
	n: size,
	hash64: *fn(hash_params: nullable *opaque, key: []u8) size,
	hash_params: nullable *opaque,
) (*map | errors::invalid | nomem) = {
	if (n == 0) {
		return errors::invalid;
	};

	let buckets: []*map::map = [];
	for (let i = 0z; i < n; i += 1) {
		let fb = match (make_fallback()) {
		case let p: *map::map => yield p;
		case nomem =>
			for (let j = 0z; j < len(buckets); j += 1) {
				map::finish(buckets[j]);
			};
			return nomem;
		};
		match (append(buckets, fb)) {
		case void => yield;
		case nomem =>
			for (let j = 0z; j < len(buckets); j += 1) {
				map::finish(buckets[j]);
			};
			return nomem;
		};
	};

	let m = match (alloc(map {
		vt = &_vt,
		n = n,
		buckets = buckets,
		hash64 = hash64,
		hash_params = hash_params,
	})) {
	case let pm: *map => yield pm;
	case nomem =>
		for (let j = 0z; j < len(buckets); j += 1) {
			map::finish(buckets[j]);
		};
		free(buckets);
		return nomem;
	};
	return m;
};
