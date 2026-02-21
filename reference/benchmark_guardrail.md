# Benchmark a guardrail with positive and negative cases

Convenience wrapper that constructs a dataset, runs
[`eval_guardrail()`](https://ian-flores.github.io/secureeval/reference/eval_guardrail.md),
and returns
[`guardrail_metrics()`](https://ian-flores.github.io/secureeval/reference/guardrail_metrics.md).

## Usage

``` r
benchmark_guardrail(guardrail, positive_cases, negative_cases)
```

## Arguments

- guardrail:

  A guardrail function or object (see
  [`eval_guardrail()`](https://ian-flores.github.io/secureeval/reference/eval_guardrail.md)).

- positive_cases:

  Character vector of inputs that SHOULD be blocked.

- negative_cases:

  Character vector of inputs that should NOT be blocked.

## Value

A named list of metrics (see
[`guardrail_metrics()`](https://ian-flores.github.io/secureeval/reference/guardrail_metrics.md)).

## Examples

``` r
# A simple guardrail that blocks inputs containing "DROP TABLE"
my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
metrics <- benchmark_guardrail(
  my_guard,
  positive_cases = c("DROP TABLE users", "SELECT 1; DROP TABLE x"),
  negative_cases = c("SELECT * FROM users", "Hello world")
)
metrics$precision
#> [1] 1
```
