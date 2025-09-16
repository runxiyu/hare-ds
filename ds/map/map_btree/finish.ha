// SPDX-License-Identifier: MPL-2.0

// Frees resources associated with a [[map]].
export fn finish(m: *map) void = {
	node_finish(m.root);
	free(m);
};

fn node_finish(n: *node) void = {
	if (!n.leaf) {
		for (let i = 0z; i < len(n.children); i += 1) {
			node_finish(n.children[i]);
		};
		free(n.children);
	};
	free(n.keys);
	free(n.vals);
	free(n);
};
