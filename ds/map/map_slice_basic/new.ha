// SPDX-License-Identifier: MPL-2.0

// Creates a new [[map]].
export fn new() (*map | nomem) = {
	let m = alloc(map {
		vt = &_vt,
		items = [],
	})?;
	return m;
};
