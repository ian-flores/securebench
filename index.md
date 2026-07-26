# securebench

> **Note:** Experimental release. APIs may change before the 1.0
> stabilization — track the lifecycle badge above for the current tier.

Security-specific benchmark datasets and harnesses for R LLM agents.
Measure prompt-injection resistance, dangerous-code detection, and
PII/secret leakage against labeled datasets; compute precision/recall/F1
metrics and confusion matrices; A/B-compare guardrail configurations
(including [secureguard](https://github.com/ian-flores/secureguard)
pipelines); and export any guardrail as a
[vitals](https://vitals.tidyverse.org/)-compatible scorer.

## Why securebench?

R already has a general-purpose LLM evaluation framework: the
tidyverse’s [vitals](https://vitals.tidyverse.org/). securebench is not
that, and doesn’t try to be. What R does *not* have is security-specific
benchmarks: labeled datasets of prompt-injection attempts, dangerous
code, and credential/PII leaks, plus harnesses that answer the questions
security work actually asks. Does my injection detector catch attacks
without blocking legitimate queries? Did tightening a guardrail re-open
an attack vector it used to catch? Which of two guardrail configurations
misses fewer threats?

securebench fills that niche. It ships labeled security datasets,
evaluates any boolean guardrail (a secureguard pipeline or a plain
function) against them, and reports the metrics that matter for security
decisions – recall on attacks, precision on benign traffic, and per-case
regressions between versions. When you want those security checks inside
a broader eval suite,
[`as_vitals_scorer()`](https://ian-flores.github.io/securebench/reference/as_vitals_scorer.md)
turns any guardrail into a scorer vitals can run, so the two packages
compose rather than compete.

## Features

| Function | Description |
|----|----|
| [`guardrail_eval()`](https://ian-flores.github.io/securebench/reference/guardrail_eval.md) | Evaluate a guardrail against a labeled data frame |
| [`guardrail_metrics()`](https://ian-flores.github.io/securebench/reference/guardrail_metrics.md) | Compute precision, recall, F1, and accuracy |
| [`guardrail_confusion()`](https://ian-flores.github.io/securebench/reference/guardrail_confusion.md) | Generate a 2x2 confusion matrix |
| [`guardrail_compare()`](https://ian-flores.github.io/securebench/reference/guardrail_compare.md) | Compare two guardrails with delta metrics and per-case diffs |
| [`guardrail_report()`](https://ian-flores.github.io/securebench/reference/guardrail_report.md) | Print a formatted report or return results as a data frame |
| [`benchmark_guardrail()`](https://ian-flores.github.io/securebench/reference/benchmark_guardrail.md) | Quick-start: benchmark from positive/negative case vectors |
| [`benchmark_pipeline()`](https://ian-flores.github.io/securebench/reference/benchmark_pipeline.md) | Evaluate a full secureguard pipeline end-to-end |
| [`as_vitals_scorer()`](https://ian-flores.github.io/securebench/reference/as_vitals_scorer.md) | Convert any guardrail to a vitals-compatible scorer function |
| [`load_reference()`](https://ian-flores.github.io/securebench/reference/load_reference.md) | Load a bundled labeled dataset (`injection_basic`, `pii_basic`, `secrets_basic`) |
| [`reference_datasets()`](https://ian-flores.github.io/securebench/reference/reference_datasets.md) | List the names of bundled datasets |

## Bundled Reference Datasets

Three small synthetic labeled datasets ship in `inst/extdata/` so you
can smoke-test guardrails without writing your own corpus first. Each is
a `data.frame` with `input` (character), `expected` (logical: `TRUE`
means the guardrail should let the row through, `FALSE` means it should
block), and `label` (category tag).

``` r

library(secureguard)
library(securebench)

df <- load_reference("injection_basic")
res <- guardrail_eval(guard_prompt_injection(), df)
guardrail_metrics(res)
```

Available datasets: `injection_basic` (~50 rows of prompt-injection vs
benign), `pii_basic` (~50 rows of email/SSN/IBAN/MAC/etc. vs benign),
`secrets_basic` (~50 rows of leaked-credential shapes vs benign). Tokens
that look like real cloud-provider keys are masked with `EXAMPLE`
markers so the bundled CSV doesn’t trip GitHub’s secret scanner. These
are smoke-test fixtures, not production benchmarks — bring your own
labeled corpus for serious evaluation.

## Companion Packages

securebench is the measurement layer of a small family of packages for
building secure LLM agents in R. Each package stands alone; together
they cover sandboxing, hardened tools, runtime guardrails, and
benchmarking:

| Package | Role |
|----|----|
| [securer](https://github.com/ian-flores/securer) | Sandboxed R execution with tool-call IPC |
| [securetools](https://github.com/ian-flores/securetools) | Pre-built security-hardened tool definitions |
| [secureguard](https://github.com/ian-flores/secureguard) | Input/code/output guardrails (injection, PII, secrets) |
| [securebench](https://github.com/ian-flores/securebench) | Security benchmark datasets and guardrail benchmarking harnesses |

secureguard enforces guardrails at runtime; securebench measures whether
those guardrails (or any boolean classifier) actually work, using
labeled datasets, precision/recall/F1 metrics, and A/B comparison. For
general LLM evaluation beyond security, use
[vitals](https://vitals.tidyverse.org/) – securebench guardrails plug
into it via
[`as_vitals_scorer()`](https://ian-flores.github.io/securebench/reference/as_vitals_scorer.md).

## Installation

``` r

# install.packages("pak")
pak::pak("ian-flores/securebench")
```

## Quick Start

``` r

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

``` r

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

[vitals](https://vitals.tidyverse.org/) is the general LLM evaluation
framework for R; securebench supplies the security-specific piece. Any
guardrail exports as a vitals-compatible scorer, so security checks slot
into your existing vitals eval suites:

``` r

scorer <- as_vitals_scorer(my_guardrail)
scorer("safe query", TRUE)    # 1 (correct)
scorer("DROP TABLE x", FALSE) # 1 (correct)
```

## Comparing Guardrails

``` r

# Define test data
data <- data.frame(
  input = c("hello", "how are you?", "DROP TABLE users", "'; DELETE FROM accounts"),
  expected = c(TRUE, TRUE, FALSE, FALSE),
  label = c("benign", "benign", "injection", "injection")
)

# Two guardrail versions to compare
guard_v1 <- function(text) !grepl("DROP", text, fixed = TRUE)
guard_v2 <- function(text) !grepl("DROP|DELETE", text)

# Evaluate both against the same dataset
result_v1 <- guardrail_eval(guard_v1, data)
result_v2 <- guardrail_eval(guard_v2, data)

# Compare: see which improved, which regressed
diff <- guardrail_compare(result_v1, result_v2)
diff$delta_f1       # positive = v2 is better
diff$improved       # cases v2 got right that v1 missed
diff$regressed      # cases v2 got wrong that v1 had right
```

## Documentation

securebench ships with two vignettes:

- **Getting Started with securebench** – walkthrough of the core
  evaluation workflow
- **Guardrail Testing Patterns** – strategies for building labeled
  datasets and iterating on guardrail accuracy

Browse the full documentation at
<https://ian-flores.github.io/securebench/>.

## Contributing

Contributions are welcome! Please file issues on
[GitHub](https://github.com/ian-flores/securebench/issues) and submit
pull requests.

## License

MIT
