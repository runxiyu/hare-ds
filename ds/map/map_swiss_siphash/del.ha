// SPDX-License-Identifier: Apache-2.0 AND MPL-2.0
// SPDX-FileCopyrightText: 2024 The Cockroach Authors
// SPDX-FileCopyrightText: 2025 Runxi Yu

use bytes;

// Deletes an item from a [[map]]. Returns the removed value or void.
export fn del(m: *map, key: []u8) (*opaque | void) = {
	if (len(m.groups) == 0) return;
	let hv = hash64(m, key);
	let t = h2(hv);
	let mask = m.group_mask;
	let off: size = (h1(hv): size) & mask;
	let idx: size = 0;

	for (true) {
		let g = &m.groups[off];
		for (let i = 0z; i < GROUP_SIZE; i += 1) {
			let c = g.ctrl[i];
			if (is_full_ctrl(c) && c == t) {
				if (bytes::equal(g.keys[i], key)) {
					let v = g.vals[i];
					g.ctrl[i] = CTRL_DELETED;
					g.keys[i] = [];
					g.vals[i] = null;
					m.used -= 1;
					m.tombs += 1;
					// elide the tombstones if exceed 1/3 of the capacity
					if (m.tombs * 3 >= capacity_slots(m)) {
						rehash_in_place(m);
					};
					match (v) {
					case null =>
						abort("map: null internal state escaped");
					case let p: *opaque =>
						return p;
					};
				};
			} else if (c == CTRL_EMPTY) {
				return;
			};
		};
		let next = probe_next(off, idx, mask);
		off = next.0;
		idx = next.1;
	};
};
