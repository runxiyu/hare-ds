// A map is a pointer to a [[vtable]] which allows for map types to implement
// common operations.
export type map = *vtable;

// The vtable type defines a set of virtual functions for a [[map]].
export type vtable = struct {
	getter: *getter,
	setter: *setter,
	deleter: *deleter,
	finisher: *finisher,
};

// The interface for a map which could be used to get values. Returns either a
// pointer to the value, or void if the key does not exist.
export type getter = fn(m: *map, key: []u8) (*opaque | void);

// Gets an item from a [[map]]. Returns a pointer to the value or void.
export fn get(m: *map, key: []u8) (*opaque | void) = {
	return m.getter(m, key);
};

// The interface for a map which could be used to set values. Returns void on
// success, or nomem if memory allocation failed. If the value already exists,
// it is replaced.
export type setter = fn(m: *map, key: []u8, value: *opaque) (void | nomem);

// Sets an item in a [[map]], replacing any existing item with the same key.
export fn set(m: *map, key: []u8, value: *opaque) (void | nomem) = {
	return m.setter(m, key, value);
};

// The interface for a map which could be used to delete values. Returns a
// pointer to the deleted value, or void if the key does not exist.
export type deleter = fn(m: *map, key: []u8) (*opaque | void);

// Deletes an item from a [[map]]. Returns the removed value or void.
export fn del(m: *map, key: []u8) (*opaque | void) = {
	return m.deleter(m, key);
};

// The interface for a map which requires a finisher function to free it.
export type finisher = fn(m: *map) void;

// Frees the map and all of its resources. Do not use the map after calling.
export fn finish(m: *map) void = {
	m.finisher(m);
};
