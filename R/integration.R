#' Benchmark a guardrail with positive and negative cases
#'
#' Convenience wrapper that constructs a data frame, runs [guardrail_eval()],
#' and returns [guardrail_metrics()].
#'
#' @param guardrail A guardrail function or object (see [guardrail_eval()]).
#' @param positive_cases Character vector of inputs that SHOULD be blocked.
#' @param negative_cases Character vector of inputs that should NOT be blocked.
#' @return A named list of metrics (see [guardrail_metrics()]).
#' @export
#' @examples
#' my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
#' metrics <- benchmark_guardrail(
#'   my_guard,
#'   positive_cases = c("DROP TABLE users", "SELECT 1; DROP TABLE x"),
#'   negative_cases = c("SELECT * FROM users", "Hello world")
#' )
#' metrics$precision
benchmark_guardrail <- function(guardrail, positive_cases, negative_cases) {
  if (!is.character(positive_cases)) {
    cli_abort("{.arg positive_cases} must be a character vector.")
  }
  if (!is.character(negative_cases)) {
    cli_abort("{.arg negative_cases} must be a character vector.")
  }

  data <- data.frame(
    input = c(positive_cases, negative_cases),
    expected = c(rep(FALSE, length(positive_cases)), rep(TRUE, length(negative_cases))),
    label = c(rep("positive", length(positive_cases)), rep("negative", length(negative_cases))),
    stringsAsFactors = FALSE
  )

  result <- guardrail_eval(guardrail, data)
  guardrail_metrics(result)
}

#' Benchmark a guardrail pipeline end-to-end
#'
#' Evaluate a secureguard pipeline against a labeled dataset.
#'
#' @param pipeline A function that takes an input and returns TRUE (pass)
#'   or FALSE (block), or an object with a `$run` method.
#' @param data A data.frame with columns `input` (character) and `expected`
#'   (logical). An optional `label` column provides category labels.
#' @return A `guardrail_eval_result` object.
#' @export
#' @examples
#' data <- data.frame(
#'   input = c("hello", "DROP TABLE users"),
#'   expected = c(TRUE, FALSE)
#' )
#' pipeline <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
#' result <- benchmark_pipeline(pipeline, data)
#' guardrail_metrics(result)
benchmark_pipeline <- function(pipeline, data) {
  fn <- if (is.function(pipeline)) {
    pipeline
  } else if (is.list(pipeline) && is.function(pipeline$run)) {
    pipeline$run
  } else {
    cli_abort("{.arg pipeline} must be a function or an object with a {.fn run} method.")
  }
  guardrail_eval(fn, data)
}
