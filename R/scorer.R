#' Aggregate evaluation scores
#'
#' Compute summary statistics from an evaluation run result.
#'
#' @param run_result An `eval_run_result` object.
#' @param threshold Score threshold for pass/fail classification. Defaults to `0.5`.
#' @return A named list with mean_score, pass_rate, by_evaluator, by_label, and total_time.
#' @export
eval_score <- function(run_result, threshold = 0.5) {
  if (!inherits(run_result, "eval_run_result")) {
    cli_abort("{.arg run_result} must be an {.cls eval_run_result}.")
  }

  all_scores <- unlist(lapply(run_result$case_results, function(cr) cr$scores))
  mean_score <- if (length(all_scores) == 0) NA_real_ else mean(all_scores)
  pass_rate <- if (length(all_scores) == 0) NA_real_ else mean(all_scores >= threshold)

  # By evaluator
  by_evaluator <- list()
  if (length(run_result$evaluator_names) > 0) {
    for (ev_name in run_result$evaluator_names) {
      ev_scores <- vapply(run_result$case_results, function(cr) {
        cr$scores[[ev_name]]
      }, numeric(1))
      by_evaluator[[ev_name]] <- mean(ev_scores)
    }
  }

  # By label
  by_label <- list()
  labels <- vapply(run_result$case_results, function(cr) {
    if (is.null(cr$label)) "(unlabeled)" else cr$label
  }, character(1))
  unique_labels <- unique(labels)
  for (lbl in unique_labels) {
    idx <- which(labels == lbl)
    lbl_scores <- unlist(lapply(run_result$case_results[idx], function(cr) cr$scores))
    by_label[[lbl]] <- if (length(lbl_scores) == 0) NA_real_ else mean(lbl_scores)
  }

  total_time <- sum(vapply(run_result$case_results, function(cr) cr$duration, numeric(1)))

  list(
    mean_score = mean_score,
    pass_rate = pass_rate,
    by_evaluator = by_evaluator,
    by_label = by_label,
    total_time = total_time
  )
}

#' Compare two evaluation runs
#'
#' Compare scores between two runs of the same dataset.
#'
#' @param result1 An `eval_run_result` (baseline).
#' @param result2 An `eval_run_result` (comparison).
#' @return A named list with delta_score, improved, regressed, and unchanged counts.
#' @export
eval_compare <- function(result1, result2) {
  if (!inherits(result1, "eval_run_result")) {
    cli_abort("{.arg result1} must be an {.cls eval_run_result}.")
  }
  if (!inherits(result2, "eval_run_result")) {
    cli_abort("{.arg result2} must be an {.cls eval_run_result}.")
  }

  scores1 <- eval_score(result1)
  scores2 <- eval_score(result2)
  delta_score <- scores2$mean_score - scores1$mean_score

  # Per-case comparison
  n <- min(length(result1$case_results), length(result2$case_results))
  improved <- 0L
  regressed <- 0L
  unchanged <- 0L

  for (i in seq_len(n)) {
    s1 <- mean(result1$case_results[[i]]$scores)
    s2 <- mean(result2$case_results[[i]]$scores)
    if (is.nan(s1)) s1 <- 0
    if (is.nan(s2)) s2 <- 0
    if (s2 > s1) {
      improved <- improved + 1L
    } else if (s2 < s1) {
      regressed <- regressed + 1L
    } else {
      unchanged <- unchanged + 1L
    }
  }

  list(
    delta_score = delta_score,
    improved = improved,
    regressed = regressed,
    unchanged = unchanged
  )
}
