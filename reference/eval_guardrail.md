# Evaluate a guardrail against a dataset

Runs a guardrail function against each test case in a dataset. Each test
case should have `input` as the text to check and `expected` as `TRUE`
(should pass) or `FALSE` (should block).

## Usage

``` r
eval_guardrail(guardrail, dataset)
```

## Arguments

- guardrail:

  A function that takes a text input and returns `TRUE` (pass) or
  `FALSE` (block), or a secureguard guardrail object.

- dataset:

  A `secureeval_dataset` of test cases.

## Value

A `guardrail_eval_result` object.
