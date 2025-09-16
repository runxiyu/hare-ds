// Frees resources associated with a [[map]].
export fn finish(m: *map) void = {
	free(m.items);
	free(m);
};
