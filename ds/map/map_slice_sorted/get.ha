use sort;

// Gets an item from a [[map]] by key, returning void if not found.
export fn get(m: *map, key: []u8) (*opaque | void) = {
	let dummy = 0;
	let probe = (key, (&dummy: *opaque));
	match (sort::search((m.items: []const opaque),
		size(([]u8, *opaque)),
		(&probe: const *opaque), &cmp_kv)) {
	case let idx: size =>
		return m.items[idx].1;
	case void =>
		return;
	};
};
