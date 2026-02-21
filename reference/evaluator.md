# Create an evaluator

An evaluator wraps a scoring function that compares a result to an
expected value.

## Usage

``` r
evaluator(name, score_fn, description = "")
```

## Arguments

- name:

  A name for the evaluator.

- score_fn:

  A function `function(result, expected)` returning a numeric value
  between 0 and 1.

- description:

  An optional description.

## Value

An object of class `secureeval_evaluator`.

## Examples

``` r
e <- evaluator("exact", function(result, expected) {
  if (identical(result, expected)) 1 else 0
})
e
#> ── Evaluator: exact ────────────────────────────────────────────────────────────
```
