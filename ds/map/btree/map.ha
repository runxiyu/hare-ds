// SPDX-License-Identifier: MPL-2.0

use ds::map;

// B-tree-based map from []u8 to *opaque.
//
// You are advised to create these with [[new]].
export type map = struct {
	vt: map::map,
	// Min degree
	t: size,
	root: *node,
};

const _vt: map::vtable = map::vtable {
	getter   = &vt_get,
	setter   = &vt_set,
	deleter  = &vt_del,
	finisher = &vt_finish,
};

fn vt_get(m: *map::map, key: []u8) (*opaque | void) = get(m: *map, key);
fn vt_set(m: *map::map, key: []u8, v: *opaque) (void | nomem) = set(m: *map, key, v);
fn vt_del(m: *map::map, key: []u8) (*opaque | void) = del(m: *map, key);
fn vt_finish(m: *map::map) void = finish(m: *map);
