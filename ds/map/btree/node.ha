export type node = struct {
	leaf: bool,
	keys: [][]u8,
	vals: []*opaque,
	children: []*node,
};

