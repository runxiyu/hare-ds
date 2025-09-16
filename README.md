# hare-ds — Data structures for Hare

**Work in progress.**

This module provides various general-purpose data structures for use in the
Hare programming language.

## Note

The maintainers of Hare would not recommend using this library.

From [Why doesn’t Hare have generics?](https://harelang.org/documentation/faq.html#why-doesn-t-hare-have-generics),

> Our semi-official casual explanation of this choice is that many programs
> have, at most, one or two really important data structures central to their
> design (and responsible for their bottlenecks), and because these data
> structures are important and central to the design, it’s wise for you to
> implement these yourself so that you can (1) understand them and (2) adapt
> them to your specific use-case. Optimizing every other data structure that
> your program makes use of, but which is not bottlenecking your performance,
> is a premature optimization.

While the above is an explanation of why Hare does not have generics, it serves
as a general argument against general-purpose data structures, such as those
implemented in this library. For examples, when a key-value map is needed but
is not a bottleneck, they may recommend using a simple slice of pairs and
iterate through them linearly.

We respectfully dissent, because we believe that general-purpose data
structures can be implemented in a way that is efficient enough for many use
cases, even if not as efficient as a hand-crafted data structure for each
specific use case. It is, instead, a premature optimization to hand-craft maps
for specific use case that would want something better than a linear search.
Even though hashmaps and tree-based maps could be considered an optimization
over a linear search, optimization should not be all-or-nothing; an appropriate
amount of optimization such as using hashmaps in many places, is better than
having linear searches everywhere where they are slow, and is also better than
hand-crafting maps for every conceivable use case where linear searches are too
slow. In practice,
[many codebases](https://paste.sr.ht/~runxiyu/a0b49d84a3c9f3b35a05dd60993a3cd9d185bfff)
use numerous auxillary maps which share similar access patterns but may use
differen types. Re-implementing a bespoke and non-general-purpose map for each
key/value type is likely a waste of effort if access patterns are similar.

Also, as a consequence of not having generics, the data structures here are not
type safe. Structures here typically use `[]u8` keys and `*opaque` values.

## Contributing

Create a branch that begins with `contrib/` and push to the
[main repo](https://forge.lindenii.org/hare/-/repos/hare-ds/)
via SSH directly.

```
git clone ssh://forge.lindenii.org/hare/:/repos/hare-ds/
cd hare-git
git checkout -b contrib/whatever
# edit and commit stuff
git push -u origin HEAD
```

## Support

[`#chat`](https://webirc.runxiyu.org/kiwiirc/#chat)
on
[irc.runxiyu.org](https://irc.runxiyu.org/).

