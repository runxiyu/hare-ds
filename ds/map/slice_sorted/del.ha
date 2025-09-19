use sort;

// Deletes an item from a [[map]]. Returns the removed value or void.
export fn del(m: *map, key: []u8) (*opaque | void) = {
	let dummy = 0;
	let probe = (key, (&dummy: *opaque));
	match (sort::search((m.items: []const opaque),
		size(([]u8, *opaque)),
		(&probe: const *opaque), &cmp_kv)) {
	case let idx: size =>
		let v = m.items[idx].1;
		delete(m.items[idx]);
		return v;
	case void =>
		return;
	};
};
