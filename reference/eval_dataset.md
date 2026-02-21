# Create an evaluation dataset

A dataset is a named collection of test cases.

## Usage

``` r
eval_dataset(cases = list(), name = "", description = "")
```

## Arguments

- cases:

  A list of `secureeval_test_case` objects.

- name:

  A name for the dataset.

- description:

  A description of the dataset.

## Value

An object of class `secureeval_dataset`.

## Examples

``` r
ds <- eval_dataset(
  cases = list(test_case("2+2", "4", label = "math")),
  name = "basic-math"
)
ds
#> ── Eval Dataset: basic-math ────────────────────────────────────────────────────
#> 1 test case(s)
#> Labels:
#> • math: 1
```
