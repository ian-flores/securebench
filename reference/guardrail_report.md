# Generate a guardrail evaluation report

Generate a guardrail evaluation report

## Usage

``` r
guardrail_report(eval_result, format = c("console", "data.frame"))
```

## Arguments

- eval_result:

  A `guardrail_eval_result` object.

- format:

  Output format: `"console"` or `"data.frame"`.

## Value

For `"console"`, prints formatted output and returns `eval_result`
invisibly. For `"data.frame"`, returns a data.frame.

## Examples

``` r
data <- data.frame(
  input = c("hello", "DROP TABLE users"),
  expected = c(TRUE, FALSE)
)
my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
result <- guardrail_eval(my_guard, data)
guardrail_report(result, format = "data.frame")
#>              input expected_pass actual_pass correct label
#> 1            hello          TRUE        TRUE    TRUE  <NA>
#> 2 DROP TABLE users         FALSE       FALSE    TRUE  <NA>
```
