#' Create a test case
#'
#' A test case represents a single input/expected-output pair for evaluation.
#'
#' @param input The input to test (string, list, or any R object).
#' @param expected The expected output, or `TRUE`/`FALSE` for pass/fail cases.
#' @param label Optional category label for grouping (e.g., "injection", "benign").
#' @param metadata A named list of additional metadata.
#' @return An object of class `secureeval_test_case`.
#' @export
#' @examples
#' tc <- test_case("What is 2+2?", "4", label = "math")
#' tc
test_case <- function(input, expected, label = NULL, metadata = list()) {
  if (missing(input)) {
    cli_abort("{.arg input} is required.")
  }
  if (missing(expected)) {
    cli_abort("{.arg expected} is required.")
  }
  if (!is.null(label) && !is.character(label)) {
    cli_abort("{.arg label} must be a character string or NULL.")
  }
  if (!is.list(metadata)) {
    cli_abort("{.arg metadata} must be a list.")
  }
  structure(
    list(
      input = input,
      expected = expected,
      label = label,
      metadata = metadata
    ),
    class = "secureeval_test_case"
  )
}

#' Test if an object is a test case
#'
#' @param x An object to test.
#' @return `TRUE` if `x` is a `secureeval_test_case`, `FALSE` otherwise.
#' @export
is_test_case <- function(x) {
  inherits(x, "secureeval_test_case")
}

#' @export
print.secureeval_test_case <- function(x, ...) {
  cli_rule("Test Case")
  input_str <- if (is.character(x$input)) x$input else deparse(x$input, nlines = 1)
  expected_str <- if (is.character(x$expected)) {
    x$expected
  } else if (is.logical(x$expected)) {
    as.character(x$expected)
  } else {
    deparse(x$expected, nlines = 1)
  }
  cli_text("Input: {input_str}")
  cli_text("Expected: {expected_str}")
  if (!is.null(x$label)) {
    cli_text("Label: {x$label}")
  }
  if (length(x$metadata) > 0) {
    cli_text("Metadata: {length(x$metadata)} item(s)")
  }
  invisible(x)
}
