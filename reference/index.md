# Package index

## Test Cases

- [`test_case()`](https://ian-flores.github.io/secureeval/reference/test_case.md)
  : Create a test case
- [`is_test_case()`](https://ian-flores.github.io/secureeval/reference/is_test_case.md)
  : Test if an object is a test case

## Datasets

- [`eval_dataset()`](https://ian-flores.github.io/secureeval/reference/eval_dataset.md)
  : Create an evaluation dataset
- [`add_cases()`](https://ian-flores.github.io/secureeval/reference/add_cases.md)
  : Add test cases to a dataset
- [`dataset_size()`](https://ian-flores.github.io/secureeval/reference/dataset_size.md)
  : Get the number of cases in a dataset
- [`dataset_summary()`](https://ian-flores.github.io/secureeval/reference/dataset_summary.md)
  : Summarize a dataset by label
- [`save_dataset()`](https://ian-flores.github.io/secureeval/reference/save_dataset.md)
  : Save a dataset to JSON
- [`load_dataset()`](https://ian-flores.github.io/secureeval/reference/load_dataset.md)
  : Load a dataset from JSON

## Evaluators

- [`evaluator()`](https://ian-flores.github.io/secureeval/reference/evaluator.md)
  : Create an evaluator
- [`is_evaluator()`](https://ian-flores.github.io/secureeval/reference/is_evaluator.md)
  : Test if an object is an evaluator
- [`eval_exact_match()`](https://ian-flores.github.io/secureeval/reference/eval_exact_match.md)
  : Built-in evaluator: exact match
- [`eval_contains()`](https://ian-flores.github.io/secureeval/reference/eval_contains.md)
  : Built-in evaluator: contains
- [`eval_regex_match()`](https://ian-flores.github.io/secureeval/reference/eval_regex_match.md)
  : Built-in evaluator: regex match
- [`eval_numeric_close()`](https://ian-flores.github.io/secureeval/reference/eval_numeric_close.md)
  : Built-in evaluator: numeric closeness
- [`eval_custom()`](https://ian-flores.github.io/secureeval/reference/eval_custom.md)
  : Built-in evaluator: custom function

## Guardrail Evaluation

- [`eval_guardrail()`](https://ian-flores.github.io/secureeval/reference/eval_guardrail.md)
  : Evaluate a guardrail against a dataset
- [`guardrail_metrics()`](https://ian-flores.github.io/secureeval/reference/guardrail_metrics.md)
  : Compute guardrail evaluation metrics
- [`confusion_matrix()`](https://ian-flores.github.io/secureeval/reference/confusion_matrix.md)
  : Create a confusion matrix from guardrail evaluation

## Runner

- [`eval_run()`](https://ian-flores.github.io/secureeval/reference/eval_run.md)
  : Run an evaluation
- [`is_eval_run_result()`](https://ian-flores.github.io/secureeval/reference/is_eval_run_result.md)
  : Test if an object is an eval run result

## Scoring

- [`eval_score()`](https://ian-flores.github.io/secureeval/reference/eval_score.md)
  : Aggregate evaluation scores
- [`eval_compare()`](https://ian-flores.github.io/secureeval/reference/eval_compare.md)
  : Compare two evaluation runs

## Reports

- [`eval_report()`](https://ian-flores.github.io/secureeval/reference/eval_report.md)
  : Generate an evaluation report
- [`guardrail_report()`](https://ian-flores.github.io/secureeval/reference/guardrail_report.md)
  : Generate a guardrail evaluation report

## Integration

- [`benchmark_guardrail()`](https://ian-flores.github.io/secureeval/reference/benchmark_guardrail.md)
  : Benchmark a guardrail with positive and negative cases
- [`benchmark_pipeline()`](https://ian-flores.github.io/secureeval/reference/benchmark_pipeline.md)
  : Benchmark a pipeline end-to-end
