# securebench

> [!CAUTION]
> **Alpha software.** This package is part of a broader effort by [Ian Flores Siaca](https://github.com/ian-flores) to develop proper AI infrastructure for the R ecosystem. It is under active development and should **not** be used in production until an official release is published. APIs may change without notice.

Benchmarking framework for guardrail accuracy in R LLM agent workflows. Evaluate guardrails against labeled datasets, compute precision/recall/F1 metrics, generate confusion matrices, compare results across iterations, and export as vitals-compatible scorers.

## Installation

```r
# install.packages("pak")
pak::pak("ian-flores/securebench")
```

## Quick Start

```r
library(securebench)

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

## Data Frame API

```r
data <- data.frame(
  input = c("normal text", "DROP TABLE users"),
  expected = c(TRUE, FALSE),
  label = c("benign", "injection")
)

result <- guardrail_eval(my_guardrail, data)
m <- guardrail_metrics(result)
cm <- guardrail_confusion(result)
guardrail_report(result)
```

## Vitals Interop

```r
scorer <- as_vitals_scorer(my_guardrail)
scorer("safe query", TRUE)    # 1 (correct)
scorer("DROP TABLE x", FALSE) # 1 (correct)
```

## License

MIT
