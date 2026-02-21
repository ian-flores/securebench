#' Evaluate a guardrail against a dataset
#'
#' Runs a guardrail function against each test case in a dataset.
#' Each test case should have `input` as the text to check and `expected`
#' as `TRUE` (should pass) or `FALSE` (should block).
#'
#' @param guardrail A function that takes a text input and returns `TRUE`
#'   (pass) or `FALSE` (block), or a secureguard guardrail object.
#' @param dataset A `secureeval_dataset` of test cases.
#' @return A `guardrail_eval_result` object.
#' @export
eval_guardrail <- function(guardrail, dataset) {
  if (!inherits(dataset, "secureeval_dataset")) {
    cli_abort("{.arg dataset} must be a {.cls secureeval_dataset}.")
  }
  # Accept either a function or a secureguard guardrail object with a $check method

  check_fn <- if (is.function(guardrail)) {
    guardrail
  } else if (is.list(guardrail) && is.function(guardrail$check)) {
    guardrail$check
  } else {
    cli_abort("{.arg guardrail} must be a function or an object with a {.fn check} method.")
  }

  results <- lapply(dataset$cases, function(tc) {
    pass <- tryCatch(
      {
        result <- check_fn(tc$input)
        isTRUE(result)
      },
      error = function(e) {
        FALSE
      }
    )
    list(
      input = tc$input,
      expected = tc$expected,
      pass = pass,
      label = tc$label
    )
  })

  structure(
    list(results = results),
    class = "guardrail_eval_result"
  )
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
guardrail_metrics <- function(eval_result) {
  if (!inherits(eval_result, "guardrail_eval_result")) {
    cli_abort("{.arg eval_result} must be a {.cls guardrail_eval_result}.")
  }

  tp <- 0L
  tn <- 0L
  fp <- 0L
  fn <- 0L


  for (r in eval_result$results) {
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
confusion_matrix <- function(eval_result) {

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

#' @export
print.guardrail_eval_result <- function(x, ...) {
  m <- guardrail_metrics(x)
  cli_rule("Guardrail Evaluation")
  cli_text("{length(x$results)} case(s) evaluated")
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
