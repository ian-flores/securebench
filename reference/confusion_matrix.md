# Create a confusion matrix from guardrail evaluation

Create a confusion matrix from guardrail evaluation

## Usage

``` r
confusion_matrix(eval_result)
```

## Arguments

- eval_result:

  A `guardrail_eval_result` object.

## Value

A 2x2 matrix with rows = predicted (blocked/passed) and columns = actual
(should_block/should_pass).
