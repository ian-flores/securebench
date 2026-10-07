# securebench

securebench tells you how well a guardrail works. You give it a
guardrail and a set of labeled examples, some that should be blocked and
some that should get through. It runs the guardrail on each one and
reports how many attacks it caught and how many harmless inputs it
blocked by mistake.

A guardrail here is any R function that takes text and returns `TRUE` to
let it through or `FALSE` to block it. Guardrails from
[secureguard](https://github.com/ian-flores/secureguard) work too.

securebench is for security benchmarks only: how well a guardrail
catches prompt injection, dangerous code, or leaked personal data and
secrets, and whether one version of a guardrail does better than
another. For general LLM evaluation in R, use the tidyverse’s
[vitals](https://vitals.tidyverse.org/). vitals has no security
datasets, and securebench doesn’t try to be an eval framework, so the
two fit together.

The package is experimental, and function names may still change.

## Installation

``` r

# install.packages("pak")
pak::pak("ian-flores/securebench")
```

## A quick look

Write down a few inputs that should be blocked and a few that shouldn’t,
then see how a guardrail does:

``` r

library(securebench)

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

Recall is the share of attacks the guardrail blocked. Precision is the
share of blocks that were real attacks rather than false alarms.

For more control, put your cases in a data frame. `expected` is `TRUE`
when the input should get through and `FALSE` when it should be blocked:

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

If the guardrail throws an error on an input, that input counts as
blocked.

## Comparing two guardrails

When you change a guardrail, run the old and new versions on the same
data and compare them. `regressed` counts the cases the new version gets
wrong that the old one got right.

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

## Bundled datasets

Three small labeled datasets come with the package so you can try a
guardrail before building your own test set. Each is a data frame with
the same `input`, `expected` and `label` columns as above.

``` r

library(secureguard)
library(securebench)

df <- load_reference("injection_basic")
res <- guardrail_eval(guard_prompt_injection(), df)
guardrail_metrics(res)
```

| Dataset | Rows | What’s in it |
|----|----|----|
| `injection_basic` | 50 | Prompt injection attempts and ordinary prompts |
| `pii_basic` | 50 | Emails, SSNs, phone numbers, credit cards, IBANs and other personal data, plus ordinary text |
| `secrets_basic` | 49 | API keys, tokens, database URLs and other credentials, plus ordinary text |

The examples are synthetic. Strings shaped like real cloud keys contain
the word `EXAMPLE` so GitHub’s secret scanner doesn’t flag the files.
These datasets are fine for a smoke test but too small to trust as a
real benchmark. For that, build a labeled set from your own data.

## Functions

| Function | What it does |
|----|----|
| [`guardrail_eval()`](https://ian-flores.github.io/securebench/reference/guardrail_eval.md) | Runs a guardrail on every row of a labeled data frame |
| [`guardrail_metrics()`](https://ian-flores.github.io/securebench/reference/guardrail_metrics.md) | Computes precision, recall, F1 and accuracy |
| [`guardrail_confusion()`](https://ian-flores.github.io/securebench/reference/guardrail_confusion.md) | Returns the 2x2 confusion matrix |
| [`guardrail_compare()`](https://ian-flores.github.io/securebench/reference/guardrail_compare.md) | Compares two runs and counts cases that got better or worse |
| [`guardrail_report()`](https://ian-flores.github.io/securebench/reference/guardrail_report.md) | Prints a report, or returns one row per case as a data frame |
| [`benchmark_guardrail()`](https://ian-flores.github.io/securebench/reference/benchmark_guardrail.md) | Shortcut: takes two vectors of cases instead of a data frame |
| [`benchmark_pipeline()`](https://ian-flores.github.io/securebench/reference/benchmark_pipeline.md) | Same as [`guardrail_eval()`](https://ian-flores.github.io/securebench/reference/guardrail_eval.md), for a function or an object with a `$run()` method |
| [`as_vitals_scorer()`](https://ian-flores.github.io/securebench/reference/as_vitals_scorer.md) | Turns a guardrail into a function that scores one case as 1 (right) or 0 (wrong) |
| [`load_reference()`](https://ian-flores.github.io/securebench/reference/load_reference.md) | Loads one of the bundled datasets |
| [`reference_datasets()`](https://ian-flores.github.io/securebench/reference/reference_datasets.md) | Lists the bundled dataset names |

To benchmark a secureguard
[`secure_pipeline()`](https://ian-flores.github.io/secureguard/reference/secure_pipeline.html),
pass one of its check functions, such as `pipeline$check_input`, rather
than the pipeline itself.

## With vitals

[`as_vitals_scorer()`](https://ian-flores.github.io/securebench/reference/as_vitals_scorer.md)
gives you a function that takes an input and the expected result and
returns 1 if the guardrail got it right, 0 if not:

``` r

scorer <- as_vitals_scorer(my_guardrail)
scorer("safe query", TRUE)    # 1 (correct)
scorer("DROP TABLE x", FALSE) # 1 (correct)
```

A vitals scorer works on a whole task’s `samples` data frame at once, so
to use this inside a vitals `Task`, call it on each row from a small
wrapper function.

## Related packages

securebench is part of a small set of packages for running LLM agents in
R more safely:

- [securer](https://github.com/ian-flores/securer) runs agent code in a
  sandbox.
- [securetools](https://github.com/ian-flores/securetools) has
  ready-made tools (file access, SQL, web requests) with limits built
  in.
- [secureguard](https://github.com/ian-flores/secureguard) checks
  prompts, generated code and outputs. securebench measures how well
  those checks work.

## Learn more

- [Getting
  started](https://ian-flores.github.io/securebench/articles/securebench.html)
- [Testing
  patterns](https://ian-flores.github.io/securebench/articles/testing-patterns.html)
- [Function
  reference](https://ian-flores.github.io/securebench/reference/)

Found a bug or have an idea? [Open an
issue](https://github.com/ian-flores/securebench/issues).

## License

MIT
