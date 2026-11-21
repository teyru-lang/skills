The Teyru class in this directory is a gauge with a property `level` that is
always between 0 and 100. Assigning -5 must read back as 0, assigning 150 must
read back as 100, and assigning 42 must read back as 42. The grading tests use
the property syntax `g.level = ...` and `g.level`.

Make the class behave that way. Keep the public API (`Gauge`, `level`).
`teyru` is on PATH; use `teyru build` and `teyru test`.
