// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2024 Drew DeVault <drew@ddevault.org>
// SPDX-FileCopyrightText: 2025 Runxi Yu <me@runxiyu.org>

use ds::map;

// Deletes an item from a [[map]].
export fn del(m: *map, key: []u8) (*opaque | void) = {
	return map::del(m.inner, key);
};
