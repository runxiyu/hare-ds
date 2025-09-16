// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use ds::set;

// Tests whether an item is present in a [[set]].
export fn contains(s: *set, key: []u8) bool = {
	return set::contains(s.inner, key);
};
