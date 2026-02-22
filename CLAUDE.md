# securebench -- Development Guide

## What This Is

An R package for benchmarking guardrail accuracy in R LLM agent workflows. Focuses on evaluating guardrails (input validation, code analysis, output filtering) with precision/recall/F1 metrics. Interoperates with the vitals package for broader eval workflows.

## Architecture

- `R/guardrail-eval.R` -- `guardrail_eval()`, `guardrail_metrics()`, `guardrail_confusion()`, `guardrail_compare()`
- `R/report.R` -- `guardrail_report()` console and data.frame output
- `R/integration.R` -- `benchmark_guardrail()`, `benchmark_pipeline()` convenience wrappers
- `R/vitals.R` -- `as_vitals_scorer()` vitals package interop
- `R/securebench-package.R` -- Package-level imports

## Development Commands

```bash
Rscript -e "devtools::test('.')"
Rscript -e "devtools::check('.')"
Rscript -e "devtools::document('.')"
```

## Key Design Decisions

- Input is always a plain data.frame with `input` (character), `expected` (logical), optional `label` (character)
- No custom dataset classes -- uses standard R data structures
- `guardrail_eval_result` is the universal result type
- secureguard is Suggests (works standalone)
- vitals is Suggests (optional interop via `as_vitals_scorer()`)

## Dependencies

- Imports: rlang, cli
- Suggests: secureguard, vitals, testthat, withr, knitr, rmarkdown
