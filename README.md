# secureeval

> [!CAUTION]
> **Alpha software.** This package is part of a broader effort by [Ian Flores Siaca](https://github.com/ian-flores) to develop proper AI infrastructure for the R ecosystem. It is under active development and should **not** be used in production until an official release is published. APIs may change without notice.

Evaluation and benchmarking framework for R LLM agents. Test agents against known scenarios, score guardrail accuracy (precision/recall/F1), run regression tests, and compare runs across iterations.

## Installation

```r
# install.packages("pak")
pak::pak("ian-flores/secureeval")
```

## Quick Start

```r
library(secureeval)

# Create test cases
ds <- eval_dataset(
  cases = list(
    test_case("What is 2+2?", "4", label = "math"),
    test_case("Say hello", "hello", label = "greeting")
  ),
  name = "basic-tests"
)

# Define your agent function
my_agent <- function(input) {
  # Your LLM agent logic here
  input
}

# Run evaluation
result <- eval_run(my_agent, ds, list(eval_exact_match()))

# View results
eval_report(result)

# Get scores
scores <- eval_score(result)
scores$mean_score
scores$pass_rate
```

## Guardrail Benchmarking

```r
# Benchmark a guardrail with known positive/negative cases
my_guardrail <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)

metrics <- benchmark_guardrail(
  my_guardrail,
  positive_cases = c("DROP TABLE users", "SELECT 1; DROP TABLE x"),
  negative_cases = c("SELECT * FROM users", "Hello world")
)
metrics$precision
metrics$recall
metrics$f1
```

## License

MIT
