// SPDX-License-Identifier: Apache-2.0 AND MPL-2.0
// SPDX-FileCopyrightText: 2024 The Cockroach Authors
// SPDX-FileCopyrightText: 2025 Runxi Yu

// Frees resources associated with a [[map]].
export fn finish(m: *map) void = {
	if (len(m.groups) != 0) {
		free(m.groups);
	};
	free(m);
};
