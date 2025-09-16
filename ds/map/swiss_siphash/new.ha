// SPDX-License-Identifier: Apache-2.0 AND MPL-2.0
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use errors;
use ds::map;
use ds::map::swiss;

// Creates a new [[map]] with an initial number of groups and the SipHash key.
//
// n_groups must be greater than zero.
export fn new(
	n_groups: size,
	siphash_key: [16]u8,
) (*map | errors::invalid | nomem) = {
	let keybox = match (alloc(siphash_key)) {
	case let kp: *[16]u8 => yield kp;
	case nomem => return nomem;
	};

	let inner = match (swiss::new(
		n_groups, &hash64, (keybox: *opaque),
	)) {
	case let sm: *swiss::map =>
		yield (sm: *map::map);
	case errors::invalid =>
		free(keybox);
		return errors::invalid;
	case nomem =>
		free(keybox);
		return nomem;
	};

	let m = match (alloc(map {
		vt = &_vt,
		inner = inner,
		key = keybox,
	})) {
	case let p: *map => yield p;
	case nomem =>
		map::finish(inner);
		free(keybox);
		return nomem;
	};
	return m;
};
