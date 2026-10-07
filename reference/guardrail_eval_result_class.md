# Guardrail evaluation result

The S7 class that
[`guardrail_eval()`](https://ian-flores.github.io/securebench/reference/guardrail_eval.md)
returns. You rarely need to create one yourself.

## Usage

``` r
guardrail_eval_result_class(results = list())
```

## Arguments

- results:

  A list with one element per case. Each element is a list with `input`,
  `expected`, `pass` and `label`.

## Examples

``` r
res <- guardrail_eval_result_class(results = list(
  list(input = "hello", expected = TRUE, pass = TRUE, label = "benign")
))
res@results[[1]]$pass
#> [1] TRUE
```
