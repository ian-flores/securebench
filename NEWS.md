# securebench 0.1.0

* Initial CRAN release.
* Renamed from secureeval; refocused on guardrail benchmarking.
* Removed generic evaluation framework (use vitals instead).
* Core exports: `guardrail_eval()`, `guardrail_metrics()`, `guardrail_confusion()`, `guardrail_compare()`, `guardrail_report()`, `benchmark_guardrail()`, `benchmark_pipeline()`, `as_vitals_scorer()`.
* Input format: plain data.frame with `input`, `expected`, optional `label` columns.
