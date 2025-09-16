// Creates a new [[map]].
export fn new() (*map | nomem) = {
	let m = alloc(map {
		vt = &_vt,
		root = null,
	})?;
	return m;
};
