// SPDX-License-Identifier: MPL-2.0

export type color = enum u8 {
	RED = 0,
	BLACK = 1,
};

export type node = struct {
	color: color,
	key: []u8,
	val: *opaque,
	left: nullable *node,
	right: nullable *node,
	parent: nullable *node,
};
