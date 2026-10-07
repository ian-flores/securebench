#' Benchmark a guardrail from two lists of cases
#'
#' A shortcut for quick checks. It builds the data frame for you, runs
#' [guardrail_eval()] and returns [guardrail_metrics()].
#'
#' @param guardrail A guardrail function or object (see [guardrail_eval()]).
#' @param positive_cases Character vector of inputs that should be blocked.
#' @param negative_cases Character vector of inputs that should get through.
#' @return A named list of metrics, as from [guardrail_metrics()].
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
  .do_benchmark <- function() {
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

  if (.trace_active()) {
    .with_span("securebench::benchmark_guardrail", {
      result <- .do_benchmark()
      .span_event("benchmark_guardrail.complete", list(
        positive_count = length(positive_cases),
        negative_count = length(negative_cases)
      ))
      result
    })
  } else {
    .do_benchmark()
  }
}

#' Benchmark a pipeline of checks
#'
#' Runs several checks that act as one guardrail on a labeled dataset.
#' It works like [guardrail_eval()], but also accepts an object with a
#' `$run()` method.
#'
#' A secureguard [secureguard::secure_pipeline()] has no `$run()` method.
#' Pass one of its check functions instead, such as
#' `benchmark_pipeline(p$check_input, data)`.
#'
#' @param pipeline A function that takes an input and returns `TRUE` (let
#'   through) or `FALSE` (block), or a list with a `$run()` function.
#' @param data A data frame with columns `input` (character) and `expected`
#'   (logical). An optional `label` column says what kind of case each row
#'   is.
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
  .do_pipeline <- function() {
    fn <- if (is.function(pipeline)) {
      pipeline
    } else if (is.list(pipeline) && is.function(pipeline$run)) {
      pipeline$run
    } else {
      cli_abort("{.arg pipeline} must be a function or an object with a {.fn run} method.")
    }
    guardrail_eval(fn, data)
  }

  if (.trace_active()) {
    .with_span("securebench::benchmark_pipeline", {
      .do_pipeline()
    })
  } else {
    .do_pipeline()
  }
}
