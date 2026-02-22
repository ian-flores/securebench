# Compute guardrail evaluation metrics

Computes precision, recall, F1, accuracy, and confusion counts from a
guardrail evaluation result.

## Usage

``` r
guardrail_metrics(eval_result)
```

## Arguments

- eval_result:

  A `guardrail_eval_result` object.

## Value

A named list with tp, tn, fp, fn, precision, recall, f1, accuracy.

## Details

Convention: blocking is the "positive" class.

- True positive: expected=FALSE (should block) and pass=FALSE (was
  blocked)

- True negative: expected=TRUE (should pass) and pass=TRUE (was passed)

- False positive: expected=TRUE (should pass) but pass=FALSE (was
  blocked)

- False negative: expected=FALSE (should block) but pass=TRUE (was
  passed)

## Examples

``` r
data <- data.frame(
  input = c("hello", "DROP TABLE users"),
  expected = c(TRUE, FALSE)
)
my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
result <- guardrail_eval(my_guard, data)
m <- guardrail_metrics(result)
m$precision
#> [1] 1
m$recall
#> [1] 1
```
