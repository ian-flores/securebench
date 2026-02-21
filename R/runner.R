#' Run an evaluation
#'
#' Execute a function against each test case in a dataset and score results
#' using the provided evaluators.
#'
#' @param fn A function taking a single input argument and returning a result.
#' @param dataset A `secureeval_dataset` of test cases.
#' @param evaluators A list of `secureeval_evaluator` objects. If empty, no scoring
#'   is performed and only results are recorded.
#' @param name A name for this evaluation run.
#' @return An `eval_run_result` object.
#' @export
#' @examples
#' ds <- eval_dataset(list(
#'   test_case("2+2", "4", label = "math"),
#'   test_case("hello", "hello", label = "echo")
#' ))
#' result <- eval_run(identity, ds, list(eval_exact_match()))
#' result
eval_run <- function(fn, dataset, evaluators = list(), name = "") {
  if (!is.function(fn)) {
    cli_abort("{.arg fn} must be a function.")
  }
  if (!inherits(dataset, "secureeval_dataset")) {
    cli_abort("{.arg dataset} must be a {.cls secureeval_dataset}.")
  }
  if (!is.list(evaluators)) {
    cli_abort("{.arg evaluators} must be a list.")
  }
  for (i in seq_along(evaluators)) {
    if (!is_evaluator(evaluators[[i]])) {
      cli_abort("Element {i} of {.arg evaluators} is not a {.cls secureeval_evaluator}.")
    }
  }

  case_results <- lapply(dataset$cases, function(tc) {
    start_time <- proc.time()["elapsed"]
    result <- tryCatch(
      fn(tc$input),
      error = function(e) {
        structure(list(message = conditionMessage(e)), class = "secureeval_error")
      }
    )
    elapsed <- as.numeric(proc.time()["elapsed"] - start_time)

    has_error <- inherits(result, "secureeval_error")
    error_msg <- if (has_error) result$message else NULL
    actual_result <- if (has_error) NULL else result

    scores <- if (length(evaluators) > 0) {
      vapply(evaluators, function(ev) {
        if (has_error) return(0)
        tryCatch(
          as.numeric(ev$score_fn(actual_result, tc$expected)),
          error = function(e) 0
        )
      }, numeric(1))
    } else {
      numeric(0)
    }
    names(scores) <- vapply(evaluators, function(ev) ev$name, character(1))

    list(
      input = tc$input,
      expected = tc$expected,
      result = actual_result,
      label = tc$label,
      scores = scores,
      duration = elapsed,
      error = error_msg
    )
  })

  structure(
    list(
      name = name,
      case_results = case_results,
      evaluator_names = vapply(evaluators, function(ev) ev$name, character(1)),
      n_cases = length(dataset$cases)
    ),
    class = "eval_run_result"
  )
}

#' Test if an object is an eval run result
#'
#' @param x An object to test.
#' @return `TRUE` if `x` is an `eval_run_result`, `FALSE` otherwise.
#' @export
is_eval_run_result <- function(x) {
  inherits(x, "eval_run_result")
}

#' @export
print.eval_run_result <- function(x, ...) {
  cli_rule("Eval Run: {x$name}")
  cli_text("{x$n_cases} case(s)")
  if (length(x$evaluator_names) > 0) {
    cli_text("Evaluators: {paste(x$evaluator_names, collapse = ', ')}")
    scores <- eval_score(x)
    cli_text("Mean score: {format_metric(scores$mean_score)}")
    cli_text("Pass rate: {format_metric(scores$pass_rate)}")
  }
  n_errors <- sum(vapply(x$case_results, function(cr) !is.null(cr$error), logical(1)))
  if (n_errors > 0) {
    cli_text("{n_errors} error(s)")
  }
  invisible(x)
}
