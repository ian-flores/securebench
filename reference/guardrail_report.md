# Generate a guardrail evaluation report

Generate a guardrail evaluation report

## Usage

``` r
guardrail_report(eval_result, format = c("console", "data.frame"))
```

## Arguments

- eval_result:

  A `guardrail_eval_result` object.

- format:

  Output format: `"console"` or `"data.frame"`.

## Value

For `"console"`, prints formatted output and returns `eval_result`
invisibly. For `"data.frame"`, returns a data.frame.
