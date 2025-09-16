// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use hash;
use hash::fnv;

fn hash64(_params: nullable *opaque, key: []u8) size = {
	let h = fnv::fnv64a();
	hash::write(&h, key);
	return fnv::sum64(&h): size;
};
