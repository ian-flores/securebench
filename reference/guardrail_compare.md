# Compare two guardrail evaluation results

Compare metrics between two guardrail evaluations of the same dataset.

## Usage

``` r
guardrail_compare(baseline, comparison)
```

## Arguments

- baseline:

  A `guardrail_eval_result` (baseline).

- comparison:

  A `guardrail_eval_result` (comparison).

## Value

A named list with delta metrics and per-case comparison counts.

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
