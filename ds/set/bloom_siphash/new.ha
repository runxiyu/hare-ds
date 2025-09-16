// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use errors;
use ds::set;
use ds::set::bloom;

// Creates a new [[set]] with the given number of bits, hash count, and SipHash key.
export fn new(
	m: size,
	k: size,
	siphash_key: [16]u8,
) (*set | errors::invalid | nomem) = {
	let keybox = match (alloc(siphash_key)) {
	case let kp: *[16]u8 => yield kp;
	case nomem => return nomem;
	};

	let inner = match (bloom::new(m, k, &hash64, (keybox: *opaque))) {
	case let bs: *bloom::set =>
		yield (bs: *set::set);
	case errors::invalid =>
		free(keybox);
		return errors::invalid;
	case nomem =>
		free(keybox);
		return nomem;
	};

	let s = match (alloc(set {
		vt = &_vt,
		inner = inner,
		key = keybox,
	})) {
	case let sp: *set => yield sp;
	case nomem =>
		set::finish(inner);
		free(keybox);
		return nomem;
	};
	return s;
};
