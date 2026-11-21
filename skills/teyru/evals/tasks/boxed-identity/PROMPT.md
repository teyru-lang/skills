The Teyru class in this directory compares two `Integer` values. `Same.of(a, b)`
must answer whether they denote the same number: true for 20 and 20, true for
1000 and 1000, false for 3 and 4.

Make the class behave that way. Keep the public API (`Same.of(Integer,
Integer)`). `teyru` is on PATH; use `teyru build` and `teyru test`.
