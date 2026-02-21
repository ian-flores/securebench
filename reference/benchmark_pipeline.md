# Benchmark a pipeline end-to-end

Evaluate a secureguard `secure_pipeline` against a dataset using the
provided evaluators. Requires the secureguard package.

## Usage

``` r
benchmark_pipeline(pipeline, dataset, evaluators)
```

## Arguments

- pipeline:

  A secureguard `secure_pipeline` object or any function that takes an
  input and returns a result.

- dataset:

  A `secureeval_dataset` of test cases.

- evaluators:

  A list of `secureeval_evaluator` objects.

## Value

An `eval_run_result` object.
