#' S7 class for guardrail evaluation results
#'
#' @name guardrail_eval_result_class
#' @param results A list of per-case result lists.
#' @examples
#' res <- guardrail_eval_result_class(results = list(
#'   list(input = "hello", expected = TRUE, pass = TRUE, label = "benign")
#' ))
#' res@results[[1]]$pass
#' @export
guardrail_eval_result_class <- S7::new_class("guardrail_eval_result", properties = list(
  results = S7::class_list
))

#' Evaluate a guardrail against a dataset
#'
#' Runs a guardrail function against each row in a data frame.
#' Each row should have `input` as the text to check and `expected`
#' as `TRUE` (should pass) or `FALSE` (should block).
#'
#' @param guardrail A function that takes a text input and returns `TRUE`
#'   (pass) or `FALSE` (block), or a secureguard guardrail object.
#' @param data A data.frame with columns `input` (character) and `expected`
#'   (logical). An optional `label` column provides category labels.
#' @return A `guardrail_eval_result` object.
#' @export
#' @examples
#' data <- data.frame(
#'   input = c("normal text", "DROP TABLE users"),
#'   expected = c(TRUE, FALSE),
#'   label = c("benign", "injection")
#' )
#' my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
#' result <- guardrail_eval(my_guard, data)
#' guardrail_metrics(result)
guardrail_eval <- function(guardrail, data) {
  if (!is.data.frame(data)) {
    cli_abort("{.arg data} must be a data.frame.")
  }
  if (!all(c("input", "expected") %in% names(data))) {
    cli_abort("{.arg data} must have columns {.field input} and {.field expected}.")
  }
  if (!is.character(data$input)) {
    cli_abort("Column {.field input} must be character.")
  }
  if (!is.logical(data$expected)) {
    cli_abort("Column {.field expected} must be logical.")
  }

  check_fn <- if (is.function(guardrail)) {
    guardrail
  } else if (is.list(guardrail) && is.function(guardrail$check)) {
    guardrail$check
  } else {
    cli_abort("{.arg guardrail} must be a function or an object with a {.fn check} method.")
  }

  has_label <- "label" %in% names(data)

  results <- lapply(seq_len(nrow(data)), function(i) {
    pass <- tryCatch(
      {
        result <- check_fn(data$input[[i]])
        isTRUE(result)
      },
      error = function(e) {
        FALSE
      }
    )
    list(
      input = data$input[[i]],
      expected = data$expected[[i]],
      pass = pass,
      label = if (has_label) data$label[[i]] else NULL
    )
  })

  guardrail_eval_result_class(results = results)
}

#' Compute guardrail evaluation metrics
#'
#' Computes precision, recall, F1, accuracy, and confusion counts from
#' a guardrail evaluation result.
#'
#' Convention: blocking is the "positive" class.
#' - True positive: expected=FALSE (should block) and pass=FALSE (was blocked)
#' - True negative: expected=TRUE (should pass) and pass=TRUE (was passed)
#' - False positive: expected=TRUE (should pass) but pass=FALSE (was blocked)
#' - False negative: expected=FALSE (should block) but pass=TRUE (was passed)
#'
#' @param eval_result A `guardrail_eval_result` object.
#' @return A named list with tp, tn, fp, fn, precision, recall, f1, accuracy.
#' @export
#' @examples
#' data <- data.frame(
#'   input = c("hello", "DROP TABLE users"),
#'   expected = c(TRUE, FALSE)
#' )
#' my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
#' result <- guardrail_eval(my_guard, data)
#' m <- guardrail_metrics(result)
#' m$precision
#' m$recall
guardrail_metrics <- function(eval_result) {
  if (!S7::S7_inherits(eval_result, guardrail_eval_result_class)) {
    cli_abort("{.arg eval_result} must be a {.cls guardrail_eval_result}.")
  }

  tp <- 0L
  tn <- 0L
  fp <- 0L
  fn <- 0L

  for (r in eval_result@results) {
    expected_pass <- isTRUE(r$expected)
    actual_pass <- isTRUE(r$pass)
    if (!expected_pass && !actual_pass) {
      tp <- tp + 1L
    } else if (expected_pass && actual_pass) {
      tn <- tn + 1L
    } else if (expected_pass && !actual_pass) {
      fp <- fp + 1L
    } else {
      fn <- fn + 1L
    }
  }

  precision <- if ((tp + fp) == 0) NA_real_ else tp / (tp + fp)
  recall <- if ((tp + fn) == 0) NA_real_ else tp / (tp + fn)
  f1 <- if (is.na(precision) || is.na(recall) || (precision + recall) == 0) {
    NA_real_
  } else {
    2 * precision * recall / (precision + recall)
  }
  total <- tp + tn + fp + fn
  accuracy <- if (total == 0) NA_real_ else (tp + tn) / total

  list(
    true_positives = tp,
    true_negatives = tn,
    false_positives = fp,
    false_negatives = fn,
    precision = precision,
    recall = recall,
    f1 = f1,
    accuracy = accuracy
  )
}

#' Create a confusion matrix from guardrail evaluation
#'
#' @param eval_result A `guardrail_eval_result` object.
#' @return A 2x2 matrix with rows = predicted (blocked/passed) and columns = actual (should_block/should_pass).
#' @export
#' @examples
#' data <- data.frame(
#'   input = c("hello", "DROP TABLE users"),
#'   expected = c(TRUE, FALSE)
#' )
#' my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
#' result <- guardrail_eval(my_guard, data)
#' guardrail_confusion(result)
guardrail_confusion <- function(eval_result) {
  m <- guardrail_metrics(eval_result)
  mat <- matrix(
    c(m$true_positives, m$false_negatives, m$false_positives, m$true_negatives),
    nrow = 2, ncol = 2,
    dimnames = list(
      predicted = c("blocked", "passed"),
      actual = c("should_block", "should_pass")
    )
  )
  mat
}

#' Compare two guardrail evaluation results
#'
#' Compare metrics between two guardrail evaluations of the same dataset.
#'
#' @param baseline A `guardrail_eval_result` (baseline).
#' @param comparison A `guardrail_eval_result` (comparison).
#' @return A named list with delta metrics and per-case comparison counts.
#' @export
#' @examples
#' data <- data.frame(
#'   input = c("hello", "DROP TABLE users"),
#'   expected = c(TRUE, FALSE)
#' )
#' guard_v1 <- function(text) !grepl("DROP", text, fixed = TRUE)
#' guard_v2 <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
#' r1 <- guardrail_eval(guard_v1, data)
#' r2 <- guardrail_eval(guard_v2, data)
#' guardrail_compare(r1, r2)
guardrail_compare <- function(baseline, comparison) {
  if (!S7::S7_inherits(baseline, guardrail_eval_result_class)) {
    cli_abort("{.arg baseline} must be a {.cls guardrail_eval_result}.")
  }
  if (!S7::S7_inherits(comparison, guardrail_eval_result_class)) {
    cli_abort("{.arg comparison} must be a {.cls guardrail_eval_result}.")
  }

  m1 <- guardrail_metrics(baseline)
  m2 <- guardrail_metrics(comparison)

  n <- min(length(baseline@results), length(comparison@results))
  improved <- 0L
  regressed <- 0L
  unchanged <- 0L

  for (i in seq_len(n)) {
    correct1 <- isTRUE(baseline@results[[i]]$expected) == isTRUE(baseline@results[[i]]$pass)
    correct2 <- isTRUE(comparison@results[[i]]$expected) == isTRUE(comparison@results[[i]]$pass)
    if (correct2 && !correct1) {
      improved <- improved + 1L
    } else if (!correct2 && correct1) {
      regressed <- regressed + 1L
    } else {
      unchanged <- unchanged + 1L
    }
  }

  list(
    delta_precision = m2$precision - m1$precision,
    delta_recall = m2$recall - m1$recall,
    delta_f1 = m2$f1 - m1$f1,
    delta_accuracy = m2$accuracy - m1$accuracy,
    improved = improved,
    regressed = regressed,
    unchanged = unchanged
  )
}

method(print, guardrail_eval_result_class) <- function(x, ...) {
  m <- guardrail_metrics(x)
  cli_rule("Guardrail Evaluation")
  cli_text("{length(x@results)} case(s) evaluated")
  cli_text("Precision: {format_metric(m$precision)}")
  cli_text("Recall: {format_metric(m$recall)}")
  cli_text("F1: {format_metric(m$f1)}")
  cli_text("Accuracy: {format_metric(m$accuracy)}")
  invisible(x)
}

#' Format a metric value for display
#' @param x A numeric value or NA.
#' @return A formatted string.
#' @noRd
format_metric <- function(x) {
  if (is.na(x)) "NA" else sprintf("%.4f", x)
}
