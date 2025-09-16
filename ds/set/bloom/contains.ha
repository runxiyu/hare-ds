// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

// Tests whether an item is present in a [[set]].
export fn contains(s: *set, key: []u8) bool = {
	let acc = s.hash64(s.hash_params, key): u64;
	for (let i = 0z; i < s.k; i += 1) {
		let pos = (acc % (s.m: u64)): size;
		let byte = pos / 8;
		let bit = pos % 8;
		let mask = 1u8 << (bit: u8);
		if ((s.bits[byte] & mask) == 0) {
			return false;
		};
		acc += STEP;
	};
	return true;
};
