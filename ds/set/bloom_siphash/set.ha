// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use ds::set;

// A Bloom filter set using SipHash for hashing.
//
// You are advised to create these with [[new]].
export type set = struct {
	vt: set::set,
	inner: *set::set,
	key: *[16]u8,
};

const _vt: set::vtable = set::vtable {
	adder    = &vt_add,
	tester   = &vt_contains,
	finisher = &vt_finish,
};

fn vt_add(s: *set::set, key: []u8) (void | nomem) = add(s: *set, key);
fn vt_contains(s: *set::set, key: []u8) bool = contains(s: *set, key);
fn vt_finish(s: *set::set) void = finish(s: *set);
