// SPDX-License-Identifier: MPL-2.0

// Frees resources associated with a [[map]].
export fn finish(m: *map) void = {
	free(m.items);
	free(m);
};
