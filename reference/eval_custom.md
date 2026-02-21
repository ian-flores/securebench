# Built-in evaluator: custom function

Wrap an arbitrary scoring function as an evaluator.

## Usage

``` r
eval_custom(fn)
```

## Arguments

- fn:

  A function `function(result, expected)` returning a numeric value
  between 0 and 1.

## Value

A `secureeval_evaluator` object.

## Examples

``` r
e <- eval_custom(function(result, expected) {
  nchar(result) / nchar(expected)
})
```
