// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2024 Drew DeVault <drew@ddevault.org>
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use errors;
use ds::map;
use ds::map::map_hashmap;

// Creates a new [[map]] with the given number of buckets.
// make_fallback is a function that creates per-bucket fallback maps.
export fn new(
	make_fallback: *fn() (*map::map | nomem),
	n: size,
) (*map | errors::invalid | nomem) = {
	let inner = match (map_hashmap::new(make_fallback, n, &hash64, null)) {
	case let hm: *map_hashmap::map =>
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
