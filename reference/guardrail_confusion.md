# Create a confusion matrix from guardrail evaluation

Create a confusion matrix from guardrail evaluation

## Usage

``` r
guardrail_confusion(eval_result)
```

## Arguments

- eval_result:

  A `guardrail_eval_result` object.

## Value

A 2x2 matrix with rows = predicted (blocked/passed) and columns = actual
(should_block/should_pass).

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
