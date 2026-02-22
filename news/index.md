# Changelog

## securebench 0.1.0

- Initial CRAN release.
- Renamed from secureeval; refocused on guardrail benchmarking.
- Removed generic evaluation framework (use vitals instead).
- Core exports:
  [`guardrail_eval()`](https://ian-flores.github.io/securebench/reference/guardrail_eval.md),
  [`guardrail_metrics()`](https://ian-flores.github.io/securebench/reference/guardrail_metrics.md),
  [`guardrail_confusion()`](https://ian-flores.github.io/securebench/reference/guardrail_confusion.md),
  [`guardrail_compare()`](https://ian-flores.github.io/securebench/reference/guardrail_compare.md),
  [`guardrail_report()`](https://ian-flores.github.io/securebench/reference/guardrail_report.md),
  [`benchmark_guardrail()`](https://ian-flores.github.io/securebench/reference/benchmark_guardrail.md),
  [`benchmark_pipeline()`](https://ian-flores.github.io/securebench/reference/benchmark_pipeline.md),
  [`as_vitals_scorer()`](https://ian-flores.github.io/securebench/reference/as_vitals_scorer.md).
- Input format: plain data.frame with `input`, `expected`, optional
  `label` columns.
