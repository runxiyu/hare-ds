// SPDX-License-Identifier: Apache-2.0 AND MPL-2.0
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use hash;
use hash::siphash;

fn hash64(params: nullable *opaque, key: []u8) size = {
	let keyptr = match (params) {
	case null =>
		abort("ds::map::swiss_siphash: missing key");
	case let p: *opaque =>
		yield (p: *[16]u8);
	};

	let h = siphash::siphash(2, 4, keyptr);
	defer hash::close(&h);
	hash::write(&h, key);
	return siphash::sum(&h): size;
};
