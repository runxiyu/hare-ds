// SPDX-License-Identifier: Apache-2.0 AND MPL-2.0
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use ds::map;

// Frees resources associated with a [[map]].
export fn finish(m: *map) void = {
	map::finish(m.inner);
	free(m);
};
