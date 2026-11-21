The Teyru class in this directory loads a value and can fail. `Loader.read(false)`
must return `"data"`; `Loader.read(true)` must fail with an `IOException` whose
message is `"missing"`. The grading tests call both, and the second call catches
the exception.

Make the class behave that way. Keep the public API (`Loader.read(boolean)`).
`teyru` is on PATH; use `teyru build` and `teyru test`.
