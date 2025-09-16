// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

// Adds an item to a [[set]].
export fn add(s: *set, key: []u8) (void | nomem) = {
	let acc = s.hash64(s.hash_params, key): u64;
	for (let i = 0z; i < s.k; i += 1) {
		let pos = (acc % (s.m: u64)): size;
		let byte = pos / 8;
		let bit = pos % 8;
		s.bits[byte] |= (1u8 << (bit: u8));
		acc += STEP;
	};
};
