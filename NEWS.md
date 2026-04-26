# securebench 0.2.1

## Bundled dataset convention fix

* The `expected` column in all three bundled reference datasets
  (`injection_basic`, `pii_basic`, `secrets_basic`) was inverted
  relative to the package's documented convention (`expected = TRUE`
  means the row should be allowed through; `expected = FALSE` means
  it should be blocked). Out-of-the-box runs of
  `guardrail_eval()` on these datasets produced NaN precision/recall
  because the ground truth was flipped. Datasets now match the
  convention; `guardrail_metrics()` returns proper scores against any
  guardrail that meaningfully blocks threats and allows benign
  inputs. Callers who had compensated for the old convention need to
  invert their handling.

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
