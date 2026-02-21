# Built-in evaluator: contains

Scores 1 if expected is found within result (both coerced to character).

## Usage

``` r
eval_contains(case_sensitive = TRUE)
```

## Arguments

- case_sensitive:

  Whether the comparison is case-sensitive. Defaults to `TRUE`.

## Value

A `secureeval_evaluator` object.

## Examples

``` r
e <- eval_contains()
e$score_fn("hello world", "world") # 1
#> [1] 1
```
