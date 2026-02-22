# Benchmark a guardrail with positive and negative cases

Convenience wrapper that constructs a data frame, runs
[`guardrail_eval()`](https://ian-flores.github.io/securebench/reference/guardrail_eval.md),
and returns
[`guardrail_metrics()`](https://ian-flores.github.io/securebench/reference/guardrail_metrics.md).

## Usage

``` r
benchmark_guardrail(guardrail, positive_cases, negative_cases)
```

## Arguments

- guardrail:

  A guardrail function or object (see
  [`guardrail_eval()`](https://ian-flores.github.io/securebench/reference/guardrail_eval.md)).

- positive_cases:

  Character vector of inputs that SHOULD be blocked.

- negative_cases:

  Character vector of inputs that should NOT be blocked.

## Value

A named list of metrics (see
[`guardrail_metrics()`](https://ian-flores.github.io/securebench/reference/guardrail_metrics.md)).

## Examples

``` r
my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
metrics <- benchmark_guardrail(
  my_guard,
  positive_cases = c("DROP TABLE users", "SELECT 1; DROP TABLE x"),
  negative_cases = c("SELECT * FROM users", "Hello world")
)
metrics$precision
#> [1] 1
```
