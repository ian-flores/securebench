# Compare two evaluation runs

Compare scores between two runs of the same dataset.

## Usage

``` r
eval_compare(result1, result2)
```

## Arguments

- result1:

  An `eval_run_result` (baseline).

- result2:

  An `eval_run_result` (comparison).

## Value

A named list with delta_score, improved, regressed, and unchanged
counts.
