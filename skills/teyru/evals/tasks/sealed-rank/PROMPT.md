The Teyru package in this directory ranks a `Shape`: a `Circle` must be `"round"`
and a `Square` must be `"flat"`. The grading tests call `Rank.of` with one of
each.

Make the package compile and behave that way. Keep the public API (`Shape`,
`Circle`, `Square`, `Rank.of(Shape)`). `teyru` is on PATH; use `teyru build`
and `teyru test`.
