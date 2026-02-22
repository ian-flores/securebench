# securebench – Development Guide

## What This Is

An R package for benchmarking guardrail accuracy in R LLM agent
workflows. Focuses on evaluating guardrails (input validation, code
analysis, output filtering) with precision/recall/F1 metrics.
Interoperates with the vitals package for broader eval workflows.

## Architecture

- `R/guardrail-eval.R` –
  [`guardrail_eval()`](https://ian-flores.github.io/securebench/reference/guardrail_eval.md),
  [`guardrail_metrics()`](https://ian-flores.github.io/securebench/reference/guardrail_metrics.md),
  [`guardrail_confusion()`](https://ian-flores.github.io/securebench/reference/guardrail_confusion.md),
  [`guardrail_compare()`](https://ian-flores.github.io/securebench/reference/guardrail_compare.md)
- `R/report.R` –
  [`guardrail_report()`](https://ian-flores.github.io/securebench/reference/guardrail_report.md)
  console and data.frame output
- `R/integration.R` –
  [`benchmark_guardrail()`](https://ian-flores.github.io/securebench/reference/benchmark_guardrail.md),
  [`benchmark_pipeline()`](https://ian-flores.github.io/securebench/reference/benchmark_pipeline.md)
  convenience wrappers
- `R/vitals.R` –
  [`as_vitals_scorer()`](https://ian-flores.github.io/securebench/reference/as_vitals_scorer.md)
  vitals package interop
- `R/securebench-package.R` – Package-level imports

## Development Commands

``` bash
Rscript -e "devtools::test('.')"
Rscript -e "devtools::check('.')"
Rscript -e "devtools::document('.')"
```

## Key Design Decisions

- Input is always a plain data.frame with `input` (character),
  `expected` (logical), optional `label` (character)
- No custom dataset classes – uses standard R data structures
- `guardrail_eval_result` is the universal result type
- secureguard is Suggests (works standalone)
- vitals is Suggests (optional interop via
  [`as_vitals_scorer()`](https://ian-flores.github.io/securebench/reference/as_vitals_scorer.md))

## Dependencies

- Imports: rlang, cli
- Suggests: secureguard, vitals, testthat, withr, knitr, rmarkdown
