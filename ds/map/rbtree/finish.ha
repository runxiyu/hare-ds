fn free_subtree(n: nullable *node) void = {
	match (n) {
	case null => return;
	case let p: *node =>
		free_subtree(p.left);
		free_subtree(p.right);
		free(p);
	};
};

// Frees resources associated with a [[map]].
export fn finish(m: *map) void = {
	free_subtree(m.root);
	free(m);
};
