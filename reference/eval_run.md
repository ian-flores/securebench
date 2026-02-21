# Run an evaluation

Execute a function against each test case in a dataset and score results
using the provided evaluators.

## Usage

``` r
eval_run(fn, dataset, evaluators = list(), name = "")
```

## Arguments

- fn:

  A function taking a single input argument and returning a result.

- dataset:

  A `secureeval_dataset` of test cases.

- evaluators:

  A list of `secureeval_evaluator` objects. If empty, no scoring is
  performed and only results are recorded.

- name:

  A name for this evaluation run.

## Value

An `eval_run_result` object.

## Examples

``` r
ds <- eval_dataset(list(
  test_case("2+2", "4", label = "math"),
  test_case("hello", "hello", label = "echo")
))
result <- eval_run(identity, ds, list(eval_exact_match()))
result
#> ── Eval Run:  ──────────────────────────────────────────────────────────────────
#> 2 case(s)
#> Evaluators: exact_match
#> Mean score: 0.5000
#> Pass rate: 0.5000
```
