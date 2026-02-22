# Wrap a guardrail as a vitals-compatible scorer

Creates a function compatible with the vitals package scoring interface.
The returned function accepts `input` and `expected` arguments and
returns a numeric score (1 for correct, 0 for incorrect).

## Usage

``` r
as_vitals_scorer(guardrail)
```

## Arguments

- guardrail:

  A guardrail function or object that takes text input and returns TRUE
  (pass) or FALSE (block).

## Value

A function with signature `function(input, expected)` returning numeric
0 or 1.

## Examples

``` r
my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
scorer <- as_vitals_scorer(my_guard)
scorer("safe query", TRUE)   # 1 (correct: expected pass, got pass)
#> [1] 1
scorer("DROP TABLE x", FALSE) # 1 (correct: expected block, got block)
#> [1] 1
```
