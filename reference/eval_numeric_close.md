# Built-in evaluator: numeric closeness

Scores 1 if the absolute difference between result and expected is
within tolerance.

## Usage

``` r
eval_numeric_close(tolerance = 1e-06)
```

## Arguments

- tolerance:

  Maximum allowed difference. Defaults to `1e-6`.

## Value

A `secureeval_evaluator` object.

## Examples

``` r
e <- eval_numeric_close()
e$score_fn(3.14159, 3.14159) # 1
#> [1] 1
e$score_fn(3.14, 3.15) # 0
#> [1] 0
```
