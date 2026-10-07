# Compare two runs of a guardrail

Compares two results from the same dataset, usually an old and a new
version of a guardrail. Cases are matched by row position, so both runs
need the rows in the same order. If one has more rows, the extra rows
are left out of the per-case counts.

## Usage

``` r
guardrail_compare(baseline, comparison)
```

## Arguments

- baseline:

  The `guardrail_eval_result` to compare against, usually the old
  version.

- comparison:

  The new `guardrail_eval_result`.

## Value

A named list. `delta_precision`, `delta_recall`, `delta_f1` and
`delta_accuracy` are the new value minus the old one. `improved` counts
cases the new version gets right and the old one got wrong, `regressed`
counts the reverse, and `unchanged` counts the rest.

## Examples

``` r
data <- data.frame(
  input = c("hello", "DROP TABLE users"),
  expected = c(TRUE, FALSE)
)
guard_v1 <- function(text) !grepl("DROP", text, fixed = TRUE)
guard_v2 <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
r1 <- guardrail_eval(guard_v1, data)
r2 <- guardrail_eval(guard_v2, data)
guardrail_compare(r1, r2)
#> $delta_precision
#> [1] 0
#> 
#> $delta_recall
#> [1] 0
#> 
#> $delta_f1
#> [1] 0
#> 
#> $delta_accuracy
#> [1] 0
#> 
#> $improved
#> [1] 0
#> 
#> $regressed
#> [1] 0
#> 
#> $unchanged
#> [1] 2
#> 
```
