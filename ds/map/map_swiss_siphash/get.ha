// SPDX-License-Identifier: Apache-2.0 AND MPL-2.0
// SPDX-FileCopyrightText: 2024 The Cockroach Authors
// SPDX-FileCopyrightText: 2025 Runxi Yu

use bytes;

// Gets an item from a [[map]] by key, returning void if not found.
export fn get(m: *map, key: []u8) (*opaque | void) = {
	if (len(m.groups) == 0) return;
	let hv = hash64(m, key): u64;
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
					match (g.vals[i]) {
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
