use sort;

fn cmp_kv(a: const *opaque, b: const *opaque) int = {
	let ka = (*(a: *([]u8, *opaque))).0;
	let kb = (*(b: *([]u8, *opaque))).0;
	return keycmp(ka, kb);
};

fn keycmp(a: []u8, b: []u8) int = {
	let n = if (len(a) < len(b)) len(a) else len(b);
	for (let i = 0z; i < n; i += 1) {
		if (a[i] < b[i]) return -1;
		if (a[i] > b[i]) return 1;
	};
	if (len(a) < len(b)) return -1;
	if (len(a) > len(b)) return 1;
	return 0;
};

fn resort(m: *map) void = {
	sort::inplace((m.items: []opaque), size(([]u8, *opaque)), &cmp_kv);
};
