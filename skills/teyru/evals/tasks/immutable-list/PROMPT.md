The Teyru package in this directory is a small shopping cart. It must keep a
growable list of item names: `add` appends, `size` counts, `items` returns the
list. The tests that grade it will assert that a new cart has one item, that
adding a second item makes the size 2, and that the second item is the one that
was added.

Make the package behave that way. Keep the public API (`Cart`, `add`, `items`,
`size`) and the package's dependencies. `teyru` is on PATH; use
`teyru build` and `teyru test` while you work.
