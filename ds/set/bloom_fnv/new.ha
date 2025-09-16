// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use errors;
use ds::set;
use ds::set::bloom;

// Creates a new [[set]] with the given number of bits and hash count.
export fn new(
	m: size,
	k: size,
) (*set | errors::invalid | nomem) = {
	let inner = match (bloom::new(m, k, &hash64, null)) {
	case let bs: *bloom::set =>
		yield (bs: *set::set);
	case errors::invalid =>
		return errors::invalid;
	case nomem =>
		return nomem;
	};

	let s = match (alloc(set {
		vt = &_vt,
		inner = inner,
	})) {
	case let sp: *set => yield sp;
	case nomem =>
		set::finish(inner);
		return nomem;
	};
	return s;
};
