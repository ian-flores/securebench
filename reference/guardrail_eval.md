# Evaluate a guardrail against a dataset

Runs a guardrail function against each row in a data frame. Each row
should have `input` as the text to check and `expected` as `TRUE`
(should pass) or `FALSE` (should block).

## Usage

``` r
guardrail_eval(guardrail, data)
```

## Arguments

- guardrail:

  A function that takes a text input and returns `TRUE` (pass) or
  `FALSE` (block), or a secureguard guardrail object.

- data:

  A data.frame with columns `input` (character) and `expected`
  (logical). An optional `label` column provides category labels.

## Value

A `guardrail_eval_result` object.

## Examples

``` r
data <- data.frame(
  input = c("normal text", "DROP TABLE users"),
  expected = c(TRUE, FALSE),
  label = c("benign", "injection")
)
my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
result <- guardrail_eval(my_guard, data)
guardrail_metrics(result)
#> $true_positives
#> [1] 1
#> 
#> $true_negatives
#> [1] 1
#> 
#> $false_positives
#> [1] 0
#> 
#> $false_negatives
#> [1] 0
#> 
#> $precision
#> [1] 1
#> 
#> $recall
#> [1] 1
#> 
#> $f1
#> [1] 1
#> 
#> $accuracy
#> [1] 1
#> 
```
