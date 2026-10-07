# Benchmark a pipeline of checks

Runs several checks that act as one guardrail on a labeled dataset. It
works like
[`guardrail_eval()`](https://ian-flores.github.io/securebench/reference/guardrail_eval.md),
but also accepts an object with a `$run()` method.

## Usage

``` r
benchmark_pipeline(pipeline, data)
```

## Arguments

- pipeline:

  A function that takes an input and returns `TRUE` (let through) or
  `FALSE` (block), or a list with a `$run()` function.

- data:

  A data frame with columns `input` (character) and `expected`
  (logical). An optional `label` column says what kind of case each row
  is.

## Value

A `guardrail_eval_result` object.

## Details

A secureguard
[`secureguard::secure_pipeline()`](https://ian-flores.github.io/secureguard/reference/secure_pipeline.html)
has no `$run()` method. Pass one of its check functions instead, such as
`benchmark_pipeline(p$check_input, data)`.

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
