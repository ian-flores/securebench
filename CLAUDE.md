# secureeval – Development Guide

## What This Is

An R package for evaluating and benchmarking LLM agents. Pure S3, no R6.

## Architecture

- `R/test-case.R` –
  [`test_case()`](https://ian-flores.github.io/secureeval/reference/test_case.md)
  S3 class
- `R/dataset.R` –
  [`eval_dataset()`](https://ian-flores.github.io/secureeval/reference/eval_dataset.md)
  collection of test cases, JSON save/load
- `R/evaluator.R` –
  [`evaluator()`](https://ian-flores.github.io/secureeval/reference/evaluator.md)
  S3 class wrapping scoring functions
- `R/evaluators.R` – Built-in evaluators: exact_match, contains, regex,
  numeric, custom
- `R/guardrail-eval.R` –
  [`eval_guardrail()`](https://ian-flores.github.io/secureeval/reference/eval_guardrail.md),
  [`guardrail_metrics()`](https://ian-flores.github.io/secureeval/reference/guardrail_metrics.md),
  [`confusion_matrix()`](https://ian-flores.github.io/secureeval/reference/confusion_matrix.md)
- `R/runner.R` –
  [`eval_run()`](https://ian-flores.github.io/secureeval/reference/eval_run.md)
  to execute functions against datasets
- `R/scorer.R` –
  [`eval_score()`](https://ian-flores.github.io/secureeval/reference/eval_score.md)
  aggregation,
  [`eval_compare()`](https://ian-flores.github.io/secureeval/reference/eval_compare.md)
  run comparison
- `R/report.R` – Console and data.frame report generation
- `R/integration.R` –
  [`benchmark_guardrail()`](https://ian-flores.github.io/secureeval/reference/benchmark_guardrail.md),
  [`benchmark_pipeline()`](https://ian-flores.github.io/secureeval/reference/benchmark_pipeline.md)
  convenience wrappers

## Development Commands

``` bash
Rscript -e "devtools::test('.')"
Rscript -e "devtools::check('.')"
Rscript -e "devtools::document('.')"
```

## Dependencies

- Imports: rlang, cli, jsonlite
- Suggests: secureguard, orchestr, securer, testthat, withr, knitr,
  rmarkdown
