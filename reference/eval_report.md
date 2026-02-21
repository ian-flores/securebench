# Generate an evaluation report

Generate an evaluation report

## Usage

``` r
eval_report(run_result, format = c("console", "data.frame"))
```

## Arguments

- run_result:

  An `eval_run_result` object.

- format:

  Output format: `"console"` for cli-formatted display, `"data.frame"`
  for a tidy data frame.

## Value

For `"console"`, prints formatted output and returns `run_result`
invisibly. For `"data.frame"`, returns a data.frame.
