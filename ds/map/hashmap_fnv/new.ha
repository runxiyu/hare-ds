// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2024 Drew DeVault <drew@ddevault.org>
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use errors;
use ds::map;
use ds::map::hashmap;

// Creates a new [[map]] with the given number of buckets.
// make_fallback is a function that creates per-bucket fallback maps.
//
// Hash collisions are virtually inevitable for typical map sizes. Therefore,
// you are required to supply a function that helps creates fallback maps, which
// are used to distinguish between items when they collide in hash.
//
// Alternatively, you may wish to use [[ds::map::swiss]] for Swiss Tables,
// which do not require a custom fallback mechanism and are typically more
// performant than hashmaps.
export fn new(
	make_fallback: *fn() (*map::map | nomem),
	n: size,
) (*map | errors::invalid | nomem) = {
	let inner = match (hashmap::new(make_fallback, n, &hash64, null)) {
	case let hm: *hashmap::map =>
		yield (hm: *map::map);
	case errors::invalid =>
		return errors::invalid;
	case nomem =>
		return nomem;
	};

	let m = match (alloc(map {
		vt = &_vt,
		inner = inner,
	})) {
	case let p: *map => yield p;
	case nomem =>
		map::finish(inner);
		return nomem;
	};
	return m;
};
