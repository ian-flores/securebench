# securebench 0.2.0

## New features

* `load_reference(name)` — loads one of three small synthetic labeled
  datasets bundled in `inst/extdata/`: `"injection_basic"`,
  `"pii_basic"`, `"secrets_basic"`. Each is a `data.frame(input,
  expected, label)` ready for `guardrail_eval()`. Intended for smoke
  tests and templates; bring your own production-shaped data for
  serious evaluations.
* `reference_datasets()` — lists the available dataset names.

# securebench 0.1.0

* Initial CRAN release.
* Renamed from secureeval; refocused on guardrail benchmarking.
* Removed generic evaluation framework (use vitals instead).
* Core exports: `guardrail_eval()`, `guardrail_metrics()`, `guardrail_confusion()`, `guardrail_compare()`, `guardrail_report()`, `benchmark_guardrail()`, `benchmark_pipeline()`, `as_vitals_scorer()`.
* Input format: plain data.frame with `input`, `expected`, optional `label` columns.
