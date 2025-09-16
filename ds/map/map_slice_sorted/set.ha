use sort;

// Sets an item in a [[map]], replacing any existing item with the same key.
export fn set(m: *map, key: []u8, value: *opaque) (void | nomem) = {
	let dummy = 0;
	let probe = (key, (&dummy: *opaque));
	match (sort::search((m.items: []const opaque),
		size(([]u8, *opaque)),
		(&probe: const *opaque), &cmp_kv)) {
	case let idx: size =>
		m.items[idx].1 = value;
	case void =>
		append(m.items, (key, value))?;
	};
	resort(m);
};
