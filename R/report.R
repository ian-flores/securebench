#' Generate an evaluation report
#'
#' @param run_result An `eval_run_result` object.
#' @param format Output format: `"console"` for cli-formatted display,
#'   `"data.frame"` for a tidy data frame.
#' @return For `"console"`, prints formatted output and returns `run_result` invisibly.
#'   For `"data.frame"`, returns a data.frame.
#' @export
eval_report <- function(run_result, format = c("console", "data.frame")) {
  if (!inherits(run_result, "eval_run_result")) {
    cli_abort("{.arg run_result} must be an {.cls eval_run_result}.")
  }
  format <- match.arg(format)

  if (format == "data.frame") {
    return(run_result_to_df(run_result))
  }

  # Console format
  scores <- eval_score(run_result)
  cli_rule("Evaluation Report: {run_result$name}")
  cli_text("{run_result$n_cases} case(s), {length(run_result$evaluator_names)} evaluator(s)")
  cli_text("")
  cli_text("Mean score: {format_metric(scores$mean_score)}")
  cli_text("Pass rate: {format_metric(scores$pass_rate)}")
  cli_text("Total time: {sprintf('%.3fs', scores$total_time)}")

  if (length(scores$by_evaluator) > 0) {
    cli_text("")
    cli_rule("By Evaluator")
    for (ev_name in names(scores$by_evaluator)) {
      cli_text("{ev_name}: {format_metric(scores$by_evaluator[[ev_name]])}")
    }
  }

  if (length(scores$by_label) > 0) {
    cli_text("")
    cli_rule("By Label")
    for (lbl in names(scores$by_label)) {
      cli_text("{lbl}: {format_metric(scores$by_label[[lbl]])}")
    }
  }

  cli_text("")
  cli_rule("Cases")
  for (i in seq_along(run_result$case_results)) {
    cr <- run_result$case_results[[i]]
    input_str <- if (is.character(cr$input)) {
      substr(cr$input, 1, 40)
    } else {
      substr(deparse(cr$input, nlines = 1), 1, 40)
    }
    score_val <- if (length(cr$scores) > 0) mean(cr$scores) else NA_real_
    status <- if (!is.null(cr$error)) {
      "ERR"
    } else if (is.na(score_val)) {
      "---"
    } else if (score_val >= 0.5) {
      "PASS"
    } else {
      "FAIL"
    }
    cli_text("[{status}] {input_str} (score: {format_metric(score_val)}, {sprintf('%.3fs', cr$duration)})")
  }

  invisible(run_result)
}

#' Convert run result to a data frame
#' @param run_result An `eval_run_result` object.
#' @return A data frame.
#' @noRd
run_result_to_df <- function(run_result) {
  if (length(run_result$evaluator_names) == 0) {
    # No evaluators: one row per case
    rows <- lapply(run_result$case_results, function(cr) {
      data.frame(
        input = deparse1_safe(cr$input),
        expected = deparse1_safe(cr$expected),
        result = deparse1_safe(cr$result),
        score = NA_real_,
        evaluator = NA_character_,
        label = if (is.null(cr$label)) NA_character_ else cr$label,
        duration = cr$duration,
        error = if (is.null(cr$error)) NA_character_ else cr$error,
        stringsAsFactors = FALSE
      )
    })
  } else {
    # One row per case x evaluator
    rows <- unlist(lapply(run_result$case_results, function(cr) {
      lapply(run_result$evaluator_names, function(ev_name) {
        data.frame(
          input = deparse1_safe(cr$input),
          expected = deparse1_safe(cr$expected),
          result = deparse1_safe(cr$result),
          score = cr$scores[[ev_name]],
          evaluator = ev_name,
          label = if (is.null(cr$label)) NA_character_ else cr$label,
          duration = cr$duration,
          error = if (is.null(cr$error)) NA_character_ else cr$error,
          stringsAsFactors = FALSE
        )
      })
    }), recursive = FALSE)
  }
  do.call(rbind, rows)
}

#' Safe deparse for data frame columns
#' @param x A value to deparse.
#' @return A character string.
#' @noRd
deparse1_safe <- function(x) {
  if (is.null(x)) return(NA_character_)
  if (is.character(x) && length(x) == 1) return(x)
  paste(deparse(x, nlines = 1), collapse = "")
}

#' Generate a guardrail evaluation report
#'
#' @param eval_result A `guardrail_eval_result` object.
#' @param format Output format: `"console"` or `"data.frame"`.
#' @return For `"console"`, prints formatted output and returns `eval_result` invisibly.
#'   For `"data.frame"`, returns a data.frame.
#' @export
guardrail_report <- function(eval_result, format = c("console", "data.frame")) {
  if (!inherits(eval_result, "guardrail_eval_result")) {
    cli_abort("{.arg eval_result} must be a {.cls guardrail_eval_result}.")
  }
  format <- match.arg(format)

  if (format == "data.frame") {
    rows <- lapply(eval_result$results, function(r) {
      data.frame(
        input = if (is.character(r$input)) r$input else deparse(r$input, nlines = 1),
        expected_pass = r$expected,
        actual_pass = r$pass,
        correct = isTRUE(r$expected) == isTRUE(r$pass),
        label = if (is.null(r$label)) NA_character_ else r$label,
        stringsAsFactors = FALSE
      )
    })
    return(do.call(rbind, rows))
  }

  # Console format
  m <- guardrail_metrics(eval_result)
  cli_rule("Guardrail Evaluation Report")
  cli_text("{length(eval_result$results)} case(s) evaluated")
  cli_text("")
  cli_text("Precision: {format_metric(m$precision)}")
  cli_text("Recall:    {format_metric(m$recall)}")
  cli_text("F1:        {format_metric(m$f1)}")
  cli_text("Accuracy:  {format_metric(m$accuracy)}")
  cli_text("")
  cli_text("TP: {m$true_positives}  FP: {m$false_positives}")
  cli_text("FN: {m$false_negatives}  TN: {m$true_negatives}")
  cli_text("")
  cli_rule("Cases")
  for (r in eval_result$results) {
    input_str <- if (is.character(r$input)) substr(r$input, 1, 50) else "..."
    correct <- isTRUE(r$expected) == isTRUE(r$pass)
    status <- if (correct) "OK" else "WRONG"
    cli_text("[{status}] {input_str}")
  }
  invisible(eval_result)
}
