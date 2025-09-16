// SPDX-License-Identifier: Apache-2.0 AND MPL-2.0
// SPDX-FileCopyrightText: 2024 The Cockroach Authors
// SPDX-FileCopyrightText: 2025 Runxi Yu

export def GROUP_SIZE: size = 8z;
export def CTRL_EMPTY: u8 = 0x80;
export def CTRL_DELETED: u8 = 0xFE;

export type group = struct {
	ctrl: [GROUP_SIZE]u8,
	keys: [GROUP_SIZE][]u8,
	vals: [GROUP_SIZE]nullable *opaque,
};

fn group_set_empty(g: *group) void = {
	for (let i = 0z; i < GROUP_SIZE; i += 1) {
		g.ctrl[i] = CTRL_EMPTY;
		g.keys[i] = [];
		g.vals[i] = null;
	};
};

fn is_full_ctrl(c: u8) bool = (c & 0x80) == 0 && c != CTRL_DELETED;

fn h1(h: u64) u64 = h >> 7u64;
fn h2(h: u64) u8 = (h & 0x7Fu64): u8;

fn probe_next(off: size, idx: size, mask: size) (size, size) = {
	let nidx = idx + 1;
	let noff = (off + nidx) & mask;
	return (noff, nidx);
};

fn capacity_slots(m: *map) size = (m.group_mask + 1) * GROUP_SIZE;

fn max_used_with_tombs(m: *map) size = {
	return (capacity_slots(m) * 7z) / 8z;
};

fn ensure_capacity_for_insert(m: *map) (void | nomem) = {
	if (m.used + m.tombs < max_used_with_tombs(m)) {
		return;
	};
	return resize(m, (m.group_mask + 1) * 2);
};

fn rehash_in_place(m: *map) void = {
	if (len(m.groups) == 0) return;
	let new_groups: []group = alloc([group{...}...], (m.group_mask + 1))!;
	for (let i = 0z; i < len(new_groups); i += 1) {
		group_set_empty(&new_groups[i]);
	};
	let old = m.groups;
	m.groups = new_groups;
	let old_groups = old;
	let old_mask = m.group_mask;
	m.used = 0;
	m.tombs = 0;

	for (let gi = 0z; gi <= old_mask; gi += 1) {
		let g = &old_groups[gi];
		for (let si = 0z; si < GROUP_SIZE; si += 1) {
			let c = g.ctrl[si];
			if (!is_full_ctrl(c)) continue;
			let k = g.keys[si];
			let v = g.vals[si];
			unchecked_put(m, k, v);
		};
	};
	free(old_groups);
};

fn resize(m: *map, new_groups_len: size) (void | nomem) = {
	if (new_groups_len == 0) new_groups_len = 1;
	let gs = match (alloc([group{...}...], new_groups_len)) {
	case let a: []group => yield a;
	case nomem => return nomem;
	};
	for (let i = 0z; i < len(gs); i += 1) {
		group_set_empty(&gs[i]);
	};
	let old = m.groups;
	let old_mask = m.group_mask;
	m.groups = gs;
	m.group_mask = new_groups_len - 1;
	m.used = 0;
	m.tombs = 0;

	for (let gi = 0z; gi <= old_mask; gi += 1) {
		let g = &old[gi];
		for (let si = 0z; si < GROUP_SIZE; si += 1) {
			let c = g.ctrl[si];
			if (!is_full_ctrl(c)) continue;
			unchecked_put(m, g.keys[si], g.vals[si]);
		};
	};
	if (len(old) != 0) {
		free(old);
	};
};

fn unchecked_put(m: *map, key: []u8, val: nullable *opaque) void = {
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
				continue;
			} else if (c == CTRL_DELETED) {
				if (first_dead is void) first_dead = i;
			} else {
				let slot = match (first_dead) {
				case void => yield i;
				case let di: size => yield di;
				};
				g.keys[slot] = key;
				g.vals[slot] = val;
				g.ctrl[slot] = t;
				m.used += 1;
				if (slot == i) {
					void;
				} else {
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
