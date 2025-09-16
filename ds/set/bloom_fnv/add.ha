// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use ds::set;

// Adds an item to a [[set]].
export fn add(s: *set, key: []u8) (void | nomem) = {
	return set::add(s.inner, key);
};
