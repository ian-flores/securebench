# Report on a guardrail run

Shows the metrics and whether the guardrail got each case right.

## Usage

``` r
guardrail_report(eval_result, format = c("console", "data.frame"))
```

## Arguments

- eval_result:

  A `guardrail_eval_result` from
  [`guardrail_eval()`](https://ian-flores.github.io/securebench/reference/guardrail_eval.md).

- format:

  `"console"` to print a summary, or `"data.frame"` to get one row per
  case.

## Value

For `"console"`, prints the metrics and a line per case marked `OK` or
`WRONG`, and returns `eval_result` invisibly. For `"data.frame"`,
returns a data frame with columns `input`, `expected_pass`,
`actual_pass`, `correct` and `label`.

## Examples

``` r
data <- data.frame(
  input = c("hello", "DROP TABLE users"),
  expected = c(TRUE, FALSE)
)
my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
result <- guardrail_eval(my_guard, data)
guardrail_report(result, format = "data.frame")
#>              input expected_pass actual_pass correct label
#> 1            hello          TRUE        TRUE    TRUE  <NA>
#> 2 DROP TABLE users         FALSE       FALSE    TRUE  <NA>
```
