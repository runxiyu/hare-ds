// SPDX-License-Identifier: Apache-2.0 AND MPL-2.0
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use errors;
use ds::map;
use ds::map::swiss;

// Creates a new [[map]] with an initial number of groups using FNV.
//
// n_groups must be greater than zero.
export fn new(
	n_groups: size,
) (*map | errors::invalid | nomem) = {
	let inner = match (swiss::new(
		n_groups, &hash64, null,
	)) {
	case let sm: *swiss::map =>
		yield (sm: *map::map);
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
