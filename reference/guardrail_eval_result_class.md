# S7 class for guardrail evaluation results

S7 class for guardrail evaluation results

## Usage

``` r
guardrail_eval_result_class(results = list())
```

## Arguments

- results:

  A list of per-case result lists.

## Examples

``` r
res <- guardrail_eval_result_class(results = list(
  list(input = "hello", expected = TRUE, pass = TRUE, label = "benign")
))
res@results[[1]]$pass
#> [1] TRUE
```
