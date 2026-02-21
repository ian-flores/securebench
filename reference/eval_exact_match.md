# Built-in evaluator: exact match

Scores 1 if the result is identical to the expected value, 0 otherwise.

## Usage

``` r
eval_exact_match()
```

## Value

A `secureeval_evaluator` object.

## Examples

``` r
e <- eval_exact_match()
e$score_fn("hello", "hello") # 1
#> [1] 1
e$score_fn("hello", "world") # 0
#> [1] 0
```
