The Teyru package in this directory ranks a `Level`. `Level.LOW` must rank 1
and `Level.HIGH` must rank 10. The grading tests call `Rank.of` for each
constant.

Make the package compile and behave that way. Keep the public API (`Level`,
`Rank.of(Level)`). `teyru` is on PATH; use `teyru build` and `teyru test`.
