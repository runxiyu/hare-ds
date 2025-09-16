// SPDX-License-Identifier: Apache-2.0 AND MPL-2.0
// SPDX-FileCopyrightText: 2024 The Cockroach Authors
// SPDX-FileCopyrightText: 2025 Runxi Yu

use errors;

// Creates a new [[map]] with an initial number of groups and hash function.
//
// n_groups must be greater than zero.
export fn new(
	n_groups: size,
	hash64: *fn(hash_params: nullable *opaque, key: []u8) size,
	hash_params: nullable *opaque,
) (*map | errors::invalid | nomem) = {
	if (n_groups == 0) {
		return errors::invalid;
	};

	let v: size = 1;
	for (v < n_groups) {
		v *= 2;
	};
	let groups_count = v;

	let gs = match (alloc([group{...}...], groups_count)) {
	case let a: []group => yield a;
	case nomem => return nomem;
	};
	for (let i = 0z; i < len(gs); i += 1) {
		group_set_empty(&gs[i]);
	};

	let m = alloc(map {
		vt = &_vt,
		group_mask = groups_count - 1,
		used = 0,
		tombs = 0,
		hash64 = hash64,
		hash_params = hash_params,
		groups = gs,
	})?;
	return m;
};
