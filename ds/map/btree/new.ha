// SPDX-License-Identifier: MPL-2.0

use errors;

// Creates a new [[map]] with minimum degree t.
//
// t must be greater than or equal to 2.
export fn new(t: size) (*map | errors::invalid | nomem) = {
	if (t < 2) {
		return errors::invalid;
	};
	let r = node_new(t, true)?;
	let m = alloc(map {
		vt = &_vt,
		t = t,
		root = r,
	})?;
	return m;
};
