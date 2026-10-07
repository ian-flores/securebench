# Run a guardrail on a labeled dataset

Runs the guardrail on each row of a data frame and records whether it
let the input through. Each row has the text to check in `input` and the
right answer in `expected`: `TRUE` if the input should get through,
`FALSE` if it should be blocked.

## Usage

``` r
guardrail_eval(guardrail, data)
```

## Arguments

- guardrail:

  The guardrail to test. This can be a function that takes a string and
  returns `TRUE` (let through) or `FALSE` (block), a secureguard
  guardrail, or a list with a `$check()` or `$run()` function. The
  function may also return a list or object with a `pass` field, such as
  a secureguard result.

- data:

  A data frame with columns `input` (character) and `expected`
  (logical). An optional `label` column says what kind of case each row
  is.

## Value

A `guardrail_eval_result` object. Pass it to
[`guardrail_metrics()`](https://ian-flores.github.io/securebench/reference/guardrail_metrics.md),
[`guardrail_confusion()`](https://ian-flores.github.io/securebench/reference/guardrail_confusion.md),
[`guardrail_report()`](https://ian-flores.github.io/securebench/reference/guardrail_report.md)
or
[`guardrail_compare()`](https://ian-flores.github.io/securebench/reference/guardrail_compare.md).

## Details

If the guardrail throws an error on an input, that input counts as
blocked.

## Examples

``` r
data <- data.frame(
  input = c("normal text", "DROP TABLE users"),
  expected = c(TRUE, FALSE),
  label = c("benign", "injection")
)
my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
result <- guardrail_eval(my_guard, data)
guardrail_metrics(result)
#> $true_positives
#> [1] 1
#> 
#> $true_negatives
#> [1] 1
#> 
#> $false_positives
#> [1] 0
#> 
#> $false_negatives
#> [1] 0
#> 
#> $precision
#> [1] 1
#> 
#> $recall
#> [1] 1
#> 
#> $f1
#> [1] 1
#> 
#> $accuracy
#> [1] 1
#> 
```
