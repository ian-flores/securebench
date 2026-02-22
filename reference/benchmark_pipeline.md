# Benchmark a guardrail pipeline end-to-end

Evaluate a secureguard pipeline against a labeled dataset.

## Usage

``` r
benchmark_pipeline(pipeline, data)
```

## Arguments

- pipeline:

  A function that takes an input and returns TRUE (pass) or FALSE
  (block), or an object with a `$run` method.

- data:

  A data.frame with columns `input` (character) and `expected`
  (logical). An optional `label` column provides category labels.

## Value

A `guardrail_eval_result` object.

## Examples

``` r
data <- data.frame(
  input = c("hello", "DROP TABLE users"),
  expected = c(TRUE, FALSE)
)
pipeline <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
result <- benchmark_pipeline(pipeline, data)
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
