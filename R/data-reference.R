#' Load a bundled test dataset
#'
#' Loads one of three small labeled datasets that come with the package,
#' so you can try a guardrail before building your own test set. Each is
#' a data frame with columns `input` (character), `expected` (logical:
#' `TRUE` if the input should get through, `FALSE` if it should be
#' blocked), and `label` (the kind of case, such as `"benign"` or
#' `"email"`).
#'
#' The datasets are:
#' \itemize{
#'   \item `"injection_basic"`: 50 rows of prompt injection attempts and
#'     ordinary prompts. Try it with
#'     [secureguard::guard_prompt_injection()].
#'   \item `"pii_basic"`: 50 rows of personal data (emails, SSNs, phone
#'     numbers, credit cards, IBANs, MAC addresses and more) and ordinary
#'     text. Try it with [secureguard::guard_input_pii()] or
#'     [secureguard::guard_output_pii()].
#'   \item `"secrets_basic"`: 49 rows of credentials (AWS and GitHub
#'     keys, JWTs, database URLs, random-looking tokens and more) and
#'     ordinary text. Try it with [secureguard::guard_output_secrets()].
#' }
#'
#' The examples are synthetic and there aren't many of them. Use them
#' for a smoke test or as a template for your own data. For a benchmark
#' you can rely on, build a labeled set from real inputs, such as your
#' production logs, and pass it to [guardrail_eval()].
#'
#' @param name The dataset name, one of the names listed above.
#' @return A data frame with columns `input`, `expected` and `label`.
#' @export
#' @examples
#' df <- load_reference("injection_basic")
#' head(df)
#' table(df$expected)
load_reference <- function(name) {
  if (!is.character(name) || length(name) != 1L) {
    cli_abort("{.arg name} must be a single character string.")
  }
  available <- reference_datasets()
  if (!name %in% available) {
    cli_abort(c(
      "Unknown reference dataset {.val {name}}.",
      "i" = "Available: {.val {available}}."
    ))
  }
  path <- system.file(
    "extdata", paste0(name, ".csv"),
    package = "securebench"
  )
  if (!nzchar(path) || !file.exists(path)) {
    cli_abort("Reference dataset file for {.val {name}} is missing from the installed package.")
  }
  df <- utils::read.csv(path, stringsAsFactors = FALSE)
  required <- c("input", "expected", "label")
  missing_cols <- setdiff(required, names(df))
  if (length(missing_cols) > 0L) {
    cli_abort(
      "Reference dataset {.val {name}} is missing columns: {.val {missing_cols}}."
    )
  }
  # Coerce the expected column — read.csv returns "TRUE"/"FALSE" literals.
  df$expected <- as.logical(df$expected)
  df
}

#' List the bundled datasets
#'
#' @return A character vector of names you can pass to [load_reference()].
#' @export
reference_datasets <- function() {
  c("injection_basic", "pii_basic", "secrets_basic")
}
