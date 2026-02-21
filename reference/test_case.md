# Create a test case

A test case represents a single input/expected-output pair for
evaluation.

## Usage

``` r
test_case(input, expected, label = NULL, metadata = list())
```

## Arguments

- input:

  The input to test (string, list, or any R object).

- expected:

  The expected output, or `TRUE`/`FALSE` for pass/fail cases.

- label:

  Optional category label for grouping (e.g., "injection", "benign").

- metadata:

  A named list of additional metadata.

## Value

An object of class `secureeval_test_case`.

## Examples

``` r
tc <- test_case("What is 2+2?", "4", label = "math")
tc
#> ── Test Case ───────────────────────────────────────────────────────────────────
#> Input: What is 2+2?
#> Expected: 4
#> Label: math
```
