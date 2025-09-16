// SPDX-License-Identifier: Apache-2.0 AND MPL-2.0
// SPDX-FileCopyrightText: 2024 The Cockroach Authors
// SPDX-FileCopyrightText: 2025 Runxi Yu

use errors;
use ds::map;

// Creates a new [[map]] with an initial number of groups and SipHash key.
//
// n_groups must be greater than zero.
export fn new(n_groups: size, siphash_key: [16]u8) (*map | errors::invalid | nomem) = {
	if (n_groups == 0) {
		return errors::invalid;
	};

	let v: size = 1;
	for (v < n_groups) {
		v *= 2;
	};
	let groups_count = v;

	let gs: []group = match (alloc([group{...}...]: []group, groups_count)) {
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
		siphash_key = siphash_key,
		groups = gs,
	})?;
	return m;
};
