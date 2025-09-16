use hash;
use hash::siphash;

fn hash64(m: *map, key: []u8) size = {
	let h = siphash::siphash(2, 4, &m.siphash_key);
	defer hash::close(&h);
	hash::write(&h, key);
	return siphash::sum(&h): size;
};
