// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2024 Drew DeVault <drew@ddevault.org>
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

// Frees resources associated with a [[map]].
export fn finish(m: *map) void = {
	for (let i = 0z; i < m.n; i += 1) {
		free(m.buckets[i]);
	};
	free(m.buckets);
	free(m);
};

