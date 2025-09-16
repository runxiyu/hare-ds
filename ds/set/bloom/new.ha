// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use errors;
use ds::set;

// Creates a new [[set]] with the given number of bits and hash functions.
//
// m controls how many bits are available in the filter. k controls how many
// hash probes are used per element. Both must be greater than zero.
export fn new(
	m: size,
	k: size,
	hash64: *fn(hash_params: nullable *opaque, key: []u8) size,
	hash_params: nullable *opaque,
) (*set | errors::invalid | nomem) = {
	if (m == 0 || k == 0) {
		return errors::invalid;
	};

	let nbytes = (m + 7) / 8;
	let bits = match (alloc([0u8...], nbytes)) {
	case let b: []u8 => yield b;
	case nomem => return nomem;
	};

	let s = match (alloc(set {
		vt = &_vt,
		bits = bits,
		m = m,
		k = k,
		hash64 = hash64,
		hash_params = hash_params,
	})) {
	case let sp: *set => yield sp;
	case nomem =>
		free(bits);
		return nomem;
	};
	return s;
};
