The Teyru class in this directory upper-cases a list of words. `Report.labels`
must return the upper-cased words in order, and an empty list for an empty
input. The grading tests call it with `List.of("ab", "c")` and with `List.of()`.

Make the class behave that way. Keep the public API (`Report.labels(List<String>)`).
`teyru` is on PATH; use `teyru build` and `teyru test`.
