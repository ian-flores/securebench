#' Benchmark a guardrail with positive and negative cases
#'
#' Convenience wrapper that constructs a dataset, runs [eval_guardrail()],
#' and returns [guardrail_metrics()].
#'
#' @param guardrail A guardrail function or object (see [eval_guardrail()]).
#' @param positive_cases Character vector of inputs that SHOULD be blocked.
#' @param negative_cases Character vector of inputs that should NOT be blocked.
#' @return A named list of metrics (see [guardrail_metrics()]).
#' @export
#' @examples
#' # A simple guardrail that blocks inputs containing "DROP TABLE"
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

  pos <- lapply(positive_cases, function(x) {
    test_case(input = x, expected = FALSE, label = "positive")
  })
  neg <- lapply(negative_cases, function(x) {
    test_case(input = x, expected = TRUE, label = "negative")
  })

  ds <- eval_dataset(
    cases = c(pos, neg),
    name = "guardrail_benchmark"
  )

  result <- eval_guardrail(guardrail, ds)
  guardrail_metrics(result)
}

#' Benchmark a pipeline end-to-end
#'
#' Evaluate a secureguard `secure_pipeline` against a dataset using the
#' provided evaluators. Requires the secureguard package.
#'
#' @param pipeline A secureguard `secure_pipeline` object or any function
#'   that takes an input and returns a result.
#' @param dataset A `secureeval_dataset` of test cases.
#' @param evaluators A list of `secureeval_evaluator` objects.
#' @return An `eval_run_result` object.
#' @export
benchmark_pipeline <- function(pipeline, dataset, evaluators) {
  # If it's a secureguard pipeline, extract its run function

  fn <- if (is.function(pipeline)) {
    pipeline
  } else if (is.list(pipeline) && is.function(pipeline$run)) {
    pipeline$run
  } else {
    cli_abort("{.arg pipeline} must be a function or an object with a {.fn run} method.")
  }
  eval_run(fn, dataset, evaluators, name = "pipeline_benchmark")
}
