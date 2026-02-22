#' Wrap a guardrail as a vitals-compatible scorer
#'
#' Creates a function compatible with the vitals package scoring interface.
#' The returned function accepts `input` and `expected` arguments and returns
#' a numeric score (1 for correct, 0 for incorrect).
#'
#' @param guardrail A guardrail function or object that takes text input and
#'   returns TRUE (pass) or FALSE (block).
#' @return A function with signature `function(input, expected)` returning
#'   numeric 0 or 1.
#' @export
#' @examples
#' my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
#' scorer <- as_vitals_scorer(my_guard)
#' scorer("safe query", TRUE)   # 1 (correct: expected pass, got pass)
#' scorer("DROP TABLE x", FALSE) # 1 (correct: expected block, got block)
as_vitals_scorer <- function(guardrail) {
  check_fn <- if (is.function(guardrail)) {
    guardrail
  } else if (is.list(guardrail) && is.function(guardrail$check)) {
    guardrail$check
  } else {
    cli_abort("{.arg guardrail} must be a function or an object with a {.fn check} method.")
  }

  function(input, expected) {
    pass <- tryCatch(isTRUE(check_fn(input)), error = function(e) FALSE)
    correct <- isTRUE(expected) == pass
    if (correct) 1 else 0
  }
}
