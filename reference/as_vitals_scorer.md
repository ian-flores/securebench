# Turn a guardrail into a per-case scoring function

Returns a function that runs the guardrail on one input and scores it 1
if the result matches `expected` and 0 if not. If the guardrail throws
an error, the input counts as blocked.

## Usage

``` r
as_vitals_scorer(guardrail)
```

## Arguments

- guardrail:

  A guardrail function or object (see
  [`guardrail_eval()`](https://ian-flores.github.io/securebench/reference/guardrail_eval.md)).

## Value

A function with arguments `input` and `expected` that returns 1 or 0.

## Details

The name refers to the [vitals](https://vitals.tidyverse.org/) package,
but a vitals scorer takes a task's whole `samples` data frame rather
than one case. To use this in a vitals `Task`, call the returned
function on each row from a small wrapper.

## Examples

``` r
my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
scorer <- as_vitals_scorer(my_guard)
scorer("safe query", TRUE)   # 1 (correct: expected pass, got pass)
#> [1] 1
scorer("DROP TABLE x", FALSE) # 1 (correct: expected block, got block)
#> [1] 1
```
