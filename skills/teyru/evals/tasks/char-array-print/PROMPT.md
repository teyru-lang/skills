The Teyru class in this directory turns a `char[]` into a `String`. `Text.of`
must return `"abc"` for the characters 97, 98 and 99, and the empty string for
an empty array.

Make the class behave that way. Keep the public API (`Text.of(char[])`).
`teyru` is on PATH; use `teyru build` and `teyru test`.
