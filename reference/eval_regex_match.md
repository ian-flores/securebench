# Built-in evaluator: regex match

Scores 1 if result matches expected as a regular expression.

## Usage

``` r
eval_regex_match()
```

## Value

A `secureeval_evaluator` object.

## Examples

``` r
e <- eval_regex_match()
e$score_fn("hello world", "^hello")
#> [1] 1
```
