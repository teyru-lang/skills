The Teyru class in this directory answers whether two strings have the same
contents. It must return true for `"hi"` and `"hi"`, true when one side is a
`StringBuilder`'s result and the other is a literal, and false for `"hi"` and
`"ho"`.

Make the class behave that way. Keep the public API (`Greeting.same(String,
String)`). `teyru` is on PATH; use `teyru build` and `teyru test`.
