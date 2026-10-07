# Confusion matrix for a guardrail

Confusion matrix for a guardrail

## Usage

``` r
guardrail_confusion(eval_result)
```

## Arguments

- eval_result:

  A `guardrail_eval_result` from
  [`guardrail_eval()`](https://ian-flores.github.io/securebench/reference/guardrail_eval.md).

## Value

A 2x2 matrix of counts. Rows are what the guardrail did (`blocked`,
`passed`) and columns are what it should have done (`should_block`,
`should_pass`).

## Examples

``` r
data <- data.frame(
  input = c("hello", "DROP TABLE users"),
  expected = c(TRUE, FALSE)
)
my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
result <- guardrail_eval(my_guard, data)
guardrail_confusion(result)
#>          actual
#> predicted should_block should_pass
#>   blocked            1           0
#>   passed             0           1
```
