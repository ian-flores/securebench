#' Guardrail evaluation result
#'
#' The S7 class that [guardrail_eval()] returns. You rarely need to create
#' one yourself.
#'
#' @name guardrail_eval_result_class
#' @param results A list with one element per case. Each element is a list
#'   with `input`, `expected`, `pass` and `label`.
#' @examples
#' res <- guardrail_eval_result_class(results = list(
#'   list(input = "hello", expected = TRUE, pass = TRUE, label = "benign")
#' ))
#' res@results[[1]]$pass
#' @export
guardrail_eval_result_class <- S7::new_class("guardrail_eval_result", properties = list(
  results = S7::class_list
))

# Resolve a guardrail-like argument to a unary check function.
# Accepts: bare functions; lists exposing `$check` or `$run`; secureguard
# S7 guardrails (detected by their `check_fn` property).
.resolve_check_fn <- function(guardrail) {
  if (is.function(guardrail)) return(guardrail)
  if (is.list(guardrail)) {
    if (is.function(guardrail$check)) return(guardrail$check)
    if (is.function(guardrail$run))   return(guardrail$run)
  }
  # secureguard S7 guardrail: has a `check_fn` property we can reach via @
  s7_fn <- tryCatch(guardrail@check_fn, error = function(e) NULL)
  if (is.function(s7_fn)) return(s7_fn)
  cli_abort(
    "{.arg guardrail} must be a function, a list with a {.fn check} or
     {.fn run} method, or a secureguard-style S7 guardrail with a
     {.field check_fn} property."
  )
}

# Coerce a guardrail result value to a single logical `pass`.
# Accepts: raw logical; secureguard `guardrail_result` S7 object with
# `@pass`; lists with a `$pass` slot.
.as_pass_logical <- function(result) {
  if (is.logical(result) && length(result) == 1L) return(isTRUE(result))
  s7_pass <- tryCatch(result@pass, error = function(e) NULL)
  if (is.logical(s7_pass) && length(s7_pass) == 1L) return(isTRUE(s7_pass))
  if (is.list(result) && !is.null(result$pass)) return(isTRUE(result$pass))
  isTRUE(result)
}

#' Run a guardrail on a labeled dataset
#'
#' Runs the guardrail on each row of a data frame and records whether it
#' let the input through. Each row has the text to check in `input` and
#' the right answer in `expected`: `TRUE` if the input should get through,
#' `FALSE` if it should be blocked.
#'
#' If the guardrail throws an error on an input, that input counts as
#' blocked.
#'
#' @param guardrail The guardrail to test. This can be a function that
#'   takes a string and returns `TRUE` (let through) or `FALSE` (block), a
#'   secureguard guardrail, or a list with a `$check()` or `$run()`
#'   function. The function may also return a list or object with a `pass`
#'   field, such as a secureguard result.
#' @param data A data frame with columns `input` (character) and `expected`
#'   (logical). An optional `label` column says what kind of case each row
#'   is.
#' @return A `guardrail_eval_result` object. Pass it to
#'   [guardrail_metrics()], [guardrail_confusion()], [guardrail_report()]
#'   or [guardrail_compare()].
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
  .do_eval <- function() {
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

    check_fn <- .resolve_check_fn(guardrail)

    has_label <- "label" %in% names(data)

    results <- lapply(seq_len(nrow(data)), function(i) {
      pass <- tryCatch(
        {
          result <- check_fn(data$input[[i]])
          .as_pass_logical(result)
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

  if (.trace_active()) {
    .with_span("securebench::guardrail_eval", {
      result <- .do_eval()
      results_list <- result@results
      passes <- vapply(results_list, function(r) r$pass, logical(1))
      .span_event("eval.complete", list(
        case_count = length(results_list),
        pass_count = sum(passes),
        fail_count = sum(!passes)
      ))
      result
    })
  } else {
    .do_eval()
  }
}

#' Precision, recall and other metrics for a guardrail
#'
#' Counts the guardrail's right and wrong calls and computes precision,
#' recall, F1 and accuracy from them.
#'
#' Blocking counts as the positive result:
#' - True positive: should be blocked, and was.
#' - True negative: should get through, and did.
#' - False positive: should get through, but was blocked.
#' - False negative: should be blocked, but got through.
#'
#' A metric is `NA` when its denominator is zero, for example precision
#' when the guardrail blocked nothing.
#'
#' @param eval_result A `guardrail_eval_result` from [guardrail_eval()].
#' @return A named list with `true_positives`, `true_negatives`,
#'   `false_positives`, `false_negatives`, `precision`, `recall`, `f1` and
#'   `accuracy`.
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
  .do_metrics <- function() {
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

  if (.trace_active()) {
    .with_span("securebench::guardrail_metrics", {
      result <- .do_metrics()
      .span_event("metrics.complete", list(
        precision = result$precision,
        recall = result$recall,
        f1 = result$f1,
        accuracy = result$accuracy
      ))
      result
    })
  } else {
    .do_metrics()
  }
}

#' Confusion matrix for a guardrail
#'
#' @param eval_result A `guardrail_eval_result` from [guardrail_eval()].
#' @return A 2x2 matrix of counts. Rows are what the guardrail did
#'   (`blocked`, `passed`) and columns are what it should have done
#'   (`should_block`, `should_pass`).
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

#' Compare two runs of a guardrail
#'
#' Compares two results from the same dataset, usually an old and a new
#' version of a guardrail. Cases are matched by row position, so both
#' runs need the rows in the same order. If one has more rows, the extra
#' rows are left out of the per-case counts.
#'
#' @param baseline The `guardrail_eval_result` to compare against, usually
#'   the old version.
#' @param comparison The new `guardrail_eval_result`.
#' @return A named list. `delta_precision`, `delta_recall`, `delta_f1` and
#'   `delta_accuracy` are the new value minus the old one. `improved`
#'   counts cases the new version gets right and the old one got wrong,
#'   `regressed` counts the reverse, and `unchanged` counts the rest.
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
  .do_compare <- function() {
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

  if (.trace_active()) {
    .with_span("securebench::guardrail_compare", {
      result <- .do_compare()
      .span_event("compare.complete", list(
        improved = result$improved,
        regressed = result$regressed,
        unchanged = result$unchanged
      ))
      result
    })
  } else {
    .do_compare()
  }
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

#' Format a metric for printing
#' @param x A number or NA.
#' @return A string with four decimal places, or `"NA"`.
#' @noRd
format_metric <- function(x) {
  if (is.na(x)) "NA" else sprintf("%.4f", x)
}
