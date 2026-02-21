# Aggregate evaluation scores

Compute summary statistics from an evaluation run result.

## Usage

``` r
eval_score(run_result, threshold = 0.5)
```

## Arguments

- run_result:

  An `eval_run_result` object.

- threshold:

  Score threshold for pass/fail classification. Defaults to `0.5`.

## Value

A named list with mean_score, pass_rate, by_evaluator, by_label, and
total_time.
