use hash;
use hash::fnv;

fn hash64(m: *map, key: []u8) size = {
	let h = fnv::fnv64a();
	hash::write(&h, key);
	return fnv::sum64(&h): size;
};
