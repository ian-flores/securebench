# securebench -- Development Guide

## What This Is

An R package providing security-specific benchmark datasets and harnesses for R LLM agents: prompt-injection resistance, dangerous-code detection, PII/secret leakage, and A/B comparison of guardrail configurations, measured with precision/recall/F1 metrics. NOT a general eval framework -- that is the tidyverse's vitals package, which securebench complements via `as_vitals_scorer()`.

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
