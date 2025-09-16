// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

// A set is a pointer to a [[vtable]] which allows for set types to implement
// common operations.
export type set = *vtable;

// The vtable type defines a set of virtual functions for a [[set]].
export type vtable = struct {
	adder: *adder,
	tester: *tester,
	finisher: *finisher,
};

// The interface for a set which could be used to add values. Returns void on
// success or nomem if memory allocation failed.
export type adder = fn(s: *set, key: []u8) (void | nomem);

// Adds an item to a [[set]].
export fn add(s: *set, key: []u8) (void | nomem) = {
	return s.adder(s, key);
};

// The interface for a set which could be used to test membership. Returns true
// if the item may be present, false otherwise.
export type tester = fn(s: *set, key: []u8) bool;

// Tests whether an item is present in a [[set]].
export fn contains(s: *set, key: []u8) bool = {
	return s.tester(s, key);
};

// The interface for a set which requires a finisher function to free it.
export type finisher = fn(s: *set) void;

// Frees the set and all of its resources.
export fn finish(s: *set) void = {
	s.finisher(s);
};
