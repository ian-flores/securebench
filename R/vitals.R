#' Turn a guardrail into a per-case scoring function
#'
#' Returns a function that runs the guardrail on one input and scores it 1
#' if the result matches `expected` and 0 if not. If the guardrail throws
#' an error, the input counts as blocked.
#'
#' The name refers to the [vitals](https://vitals.tidyverse.org/) package,
#' but a vitals scorer takes a task's whole `samples` data frame rather
#' than one case. To use this in a vitals `Task`, call the returned
#' function on each row from a small wrapper.
#'
#' @param guardrail A guardrail function or object (see [guardrail_eval()]).
#' @return A function with arguments `input` and `expected` that returns
#'   1 or 0.
#' @export
#' @examples
#' my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
#' scorer <- as_vitals_scorer(my_guard)
#' scorer("safe query", TRUE)   # 1 (correct: expected pass, got pass)
#' scorer("DROP TABLE x", FALSE) # 1 (correct: expected block, got block)
as_vitals_scorer <- function(guardrail) {
  check_fn <- .resolve_check_fn(guardrail)

  function(input, expected) {
    pass <- tryCatch(
      .as_pass_logical(check_fn(input)),
      error = function(e) FALSE
    )
    correct <- isTRUE(expected) == pass
    if (correct) 1 else 0
  }
}
