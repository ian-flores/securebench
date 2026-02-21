#' Create an evaluator
#'
#' An evaluator wraps a scoring function that compares a result to an expected value.
#'
#' @param name A name for the evaluator.
#' @param score_fn A function `function(result, expected)` returning a numeric value
#'   between 0 and 1.
#' @param description An optional description.
#' @return An object of class `secureeval_evaluator`.
#' @export
#' @examples
#' e <- evaluator("exact", function(result, expected) {
#'   if (identical(result, expected)) 1 else 0
#' })
#' e
evaluator <- function(name, score_fn, description = "") {
  if (!is.character(name) || length(name) != 1 || !nzchar(name)) {
    cli_abort("{.arg name} must be a non-empty character string.")
  }
  if (!is.function(score_fn)) {
    cli_abort("{.arg score_fn} must be a function.")
  }
  if (!is.character(description) || length(description) != 1) {
    cli_abort("{.arg description} must be a single character string.")
  }
  structure(
    list(
      name = name,
      score_fn = score_fn,
      description = description
    ),
    class = "secureeval_evaluator"
  )
}

#' Test if an object is an evaluator
#'
#' @param x An object to test.
#' @return `TRUE` if `x` is a `secureeval_evaluator`, `FALSE` otherwise.
#' @export
is_evaluator <- function(x) {
  inherits(x, "secureeval_evaluator")
}

#' @export
print.secureeval_evaluator <- function(x, ...) {
  cli_rule("Evaluator: {x$name}")
  if (nzchar(x$description)) {
    cli_text(x$description)
  }
  invisible(x)
}
