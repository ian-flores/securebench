# secureeval -- Development Guide

## What This Is

An R package for evaluating and benchmarking LLM agents. Pure S3, no R6.

## Architecture

- `R/test-case.R` -- `test_case()` S3 class
- `R/dataset.R` -- `eval_dataset()` collection of test cases, JSON save/load
- `R/evaluator.R` -- `evaluator()` S3 class wrapping scoring functions
- `R/evaluators.R` -- Built-in evaluators: exact_match, contains, regex, numeric, custom
- `R/guardrail-eval.R` -- `eval_guardrail()`, `guardrail_metrics()`, `confusion_matrix()`
- `R/runner.R` -- `eval_run()` to execute functions against datasets
- `R/scorer.R` -- `eval_score()` aggregation, `eval_compare()` run comparison
- `R/report.R` -- Console and data.frame report generation
- `R/integration.R` -- `benchmark_guardrail()`, `benchmark_pipeline()` convenience wrappers

## Development Commands

```bash
Rscript -e "devtools::test('.')"
Rscript -e "devtools::check('.')"
Rscript -e "devtools::document('.')"
```

## Dependencies

- Imports: rlang, cli, jsonlite
- Suggests: secureguard, orchestr, securer, testthat, withr, knitr, rmarkdown
