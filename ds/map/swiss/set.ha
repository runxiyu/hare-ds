// SPDX-License-Identifier: Apache-2.0 AND MPL-2.0
// SPDX-FileCopyrightText: 2024 The Cockroach Authors
// SPDX-FileCopyrightText: 2025 Runxi Yu

use bytes;

// Sets an item in a [[map]], replacing any existing item with the same key.
export fn set(m: *map, key: []u8, value: *opaque) (void | nomem) = {
	let need_insert = true;

	if (len(m.groups) != 0) {
		let hv0 = m.hash64(m.hash_params, key);
		let t0 = h2(hv0: u64);
		let mask0 = m.group_mask;
		let off0: size = (h1(hv0: u64): size) & mask0;
		let idx0: size = 0;

		need_insert = false;
		for (true) {
			let g = &m.groups[off0];

			for (let i = 0z; i < GROUP_SIZE; i += 1) {
				let c = g.ctrl[i];
				if (is_full_ctrl(c) && c == t0) {
					if (bytes::equal(g.keys[i], key)) {
						g.vals[i] = value;
						return;
					};
				} else if (c == CTRL_EMPTY) {
					need_insert = true;
					break;
				};
			};

			if (need_insert) {
				break;
			};

			let next = probe_next(off0, idx0, mask0);
			off0 = next.0;
			idx0 = next.1;
		};
	} else {
		need_insert = true;
	};

	if (!need_insert) {
		return;
	};

	match (ensure_capacity_for_insert(m)) {
	case void => yield;
	case nomem => return nomem;
	};

	let hv = m.hash64(m.hash_params, key): u64;
	let t = h2(hv);
	let mask = m.group_mask;
	let off: size = (h1(hv): size) & mask;
	let idx: size = 0;

	for (true) {
		let g = &m.groups[off];
		let first_dead: (size | void) = void;

		for (let i = 0z; i < GROUP_SIZE; i += 1) {
			let c = g.ctrl[i];
			if (is_full_ctrl(c)) {
				if (c == t && bytes::equal(g.keys[i], key)) {
					g.vals[i] = value;
					return;
				};
				continue;
			} else if (c == CTRL_DELETED) {
				if (first_dead is void) first_dead = i;
			} else {
				let slot = match (first_dead) {
				case void => yield i;
				case let di: size => yield di;
				};
				g.keys[slot] = key;
				g.vals[slot] = value;
				g.ctrl[slot] = t;
				m.used += 1;
				if (slot != i) {
					m.tombs -= 1;
				};
				return;
			};
		};

		let next = probe_next(off, idx, mask);
		off = next.0;
		idx = next.1;
	};
};
