#' Built-in evaluator: exact match
#'
#' Scores 1 if the result is identical to the expected value, 0 otherwise.
#'
#' @return A `secureeval_evaluator` object.
#' @export
#' @examples
#' e <- eval_exact_match()
#' e$score_fn("hello", "hello") # 1
#' e$score_fn("hello", "world") # 0
eval_exact_match <- function() {
  evaluator(
    name = "exact_match",
    score_fn = function(result, expected) {
      if (identical(result, expected)) 1 else 0
    },
    description = "Scores 1 if result is identical to expected, 0 otherwise."
  )
}

#' Built-in evaluator: contains
#'
#' Scores 1 if expected is found within result (both coerced to character).
#'
#' @param case_sensitive Whether the comparison is case-sensitive. Defaults to `TRUE`.
#' @return A `secureeval_evaluator` object.
#' @export
#' @examples
#' e <- eval_contains()
#' e$score_fn("hello world", "world") # 1
eval_contains <- function(case_sensitive = TRUE) {
  evaluator(
    name = "contains",
    score_fn = function(result, expected) {
      r <- as.character(result)
      e <- as.character(expected)
      if (!case_sensitive) {
        r <- tolower(r)
        e <- tolower(e)
      }
      if (grepl(e, r, fixed = TRUE)) 1 else 0
    },
    description = "Scores 1 if expected is found in result."
  )
}

#' Built-in evaluator: regex match
#'
#' Scores 1 if result matches expected as a regular expression.
#'
#' @return A `secureeval_evaluator` object.
#' @export
#' @examples
#' e <- eval_regex_match()
#' e$score_fn("hello world", "^hello")
eval_regex_match <- function() {
  evaluator(
    name = "regex_match",
    score_fn = function(result, expected) {
      r <- as.character(result)
      e <- as.character(expected)
      if (grepl(e, r, perl = TRUE)) 1 else 0
    },
    description = "Scores 1 if result matches expected as a regex."
  )
}

#' Built-in evaluator: numeric closeness
#'
#' Scores 1 if the absolute difference between result and expected is within tolerance.
#'
#' @param tolerance Maximum allowed difference. Defaults to `1e-6`.
#' @return A `secureeval_evaluator` object.
#' @export
#' @examples
#' e <- eval_numeric_close()
#' e$score_fn(3.14159, 3.14159) # 1
#' e$score_fn(3.14, 3.15) # 0
eval_numeric_close <- function(tolerance = 1e-6) {
  evaluator(
    name = "numeric_close",
    score_fn = function(result, expected) {
      r <- suppressWarnings(as.numeric(result))
      e <- suppressWarnings(as.numeric(expected))
      if (is.na(r) || is.na(e)) return(0)
      if (abs(r - e) <= tolerance) 1 else 0
    },
    description = paste0("Scores 1 if abs(result - expected) <= ", tolerance, ".")
  )
}

#' Built-in evaluator: custom function
#'
#' Wrap an arbitrary scoring function as an evaluator.
#'
#' @param fn A function `function(result, expected)` returning a numeric value
#'   between 0 and 1.
#' @return A `secureeval_evaluator` object.
#' @export
#' @examples
#' e <- eval_custom(function(result, expected) {
#'   nchar(result) / nchar(expected)
#' })
eval_custom <- function(fn) {
  if (!is.function(fn)) {
    cli_abort("{.arg fn} must be a function.")
  }
  evaluator(
    name = "custom",
    score_fn = fn,
    description = "Custom evaluator function."
  )
}
