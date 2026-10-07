# Precision, recall and other metrics for a guardrail

Counts the guardrail's right and wrong calls and computes precision,
recall, F1 and accuracy from them.

## Usage

``` r
guardrail_metrics(eval_result)
```

## Arguments

- eval_result:

  A `guardrail_eval_result` from
  [`guardrail_eval()`](https://ian-flores.github.io/securebench/reference/guardrail_eval.md).

## Value

A named list with `true_positives`, `true_negatives`, `false_positives`,
`false_negatives`, `precision`, `recall`, `f1` and `accuracy`.

## Details

Blocking counts as the positive result:

- True positive: should be blocked, and was.

- True negative: should get through, and did.

- False positive: should get through, but was blocked.

- False negative: should be blocked, but got through.

A metric is `NA` when its denominator is zero, for example precision
when the guardrail blocked nothing.

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
