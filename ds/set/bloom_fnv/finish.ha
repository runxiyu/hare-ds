// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use ds::set;

// Frees resources associated with a [[set]].
export fn finish(s: *set) void = {
	set::finish(s.inner);
	free(s);
};
