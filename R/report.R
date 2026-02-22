#' Generate a guardrail evaluation report
#'
#' @param eval_result A `guardrail_eval_result` object.
#' @param format Output format: `"console"` or `"data.frame"`.
#' @return For `"console"`, prints formatted output and returns `eval_result` invisibly.
#'   For `"data.frame"`, returns a data.frame.
#' @export
#' @examples
#' data <- data.frame(
#'   input = c("hello", "DROP TABLE users"),
#'   expected = c(TRUE, FALSE)
#' )
#' my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
#' result <- guardrail_eval(my_guard, data)
#' guardrail_report(result, format = "data.frame")
guardrail_report <- function(eval_result, format = c("console", "data.frame")) {
  if (!S7::S7_inherits(eval_result, guardrail_eval_result_class)) {
    cli_abort("{.arg eval_result} must be a {.cls guardrail_eval_result}.")
  }
  format <- match.arg(format)

  if (format == "data.frame") {
    rows <- lapply(eval_result@results, function(r) {
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
  cli_text("{length(eval_result@results)} case(s) evaluated")
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
  for (r in eval_result@results) {
    input_str <- if (is.character(r$input)) substr(r$input, 1, 50) else "..."
    correct <- isTRUE(r$expected) == isTRUE(r$pass)
    status <- if (correct) "OK" else "WRONG"
    cli_text("[{status}] {input_str}")
  }
  invisible(eval_result)
}
