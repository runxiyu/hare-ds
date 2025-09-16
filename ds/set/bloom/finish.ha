// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

// Frees resources associated with a [[set]].
export fn finish(s: *set) void = {
	free(s.bits);
	free(s);
};
