#' Bundled reference datasets for guardrail benchmarking
#'
#' Ships three small synthetic, labeled datasets suitable as
#' quick-start benchmarks for the common guardrail families. Each
#' dataset is a `data.frame` with columns `input` (character),
#' `expected` (logical — whether the row should be blocked), and
#' `label` (category tag for slicing results).
#'
#' Available dataset names:
#' \itemize{
#'   \item `"injection_basic"` — classic prompt-injection patterns and
#'     benign prompts. ~50 rows. Use against
#'     [secureguard::guard_prompt_injection()] and friends.
#'   \item `"pii_basic"` — PII strings (emails, SSN-shaped, phones,
#'     credit cards, IBAN, MAC, etc.) plus benign text. ~50 rows. Use
#'     against [secureguard::guard_input_pii()] or
#'     [secureguard::guard_output_pii()].
#'   \item `"secrets_basic"` — secret-looking tokens (AWS, GitHub, JWT,
#'     database URLs, high-entropy strings) plus benign text. ~50 rows.
#'     Use against [secureguard::guard_output_secrets()].
#' }
#'
#' The datasets are intentionally small and synthetic. They are meant
#' as smoke tests and ergonomic templates, not as a rigorous
#' benchmark. For serious evaluation, bring your own labeled corpus
#' (ideally harvested from production logs) and pass it directly to
#' [guardrail_eval()].
#'
#' @param name Character scalar; one of the names listed above.
#' @return A `data.frame` with columns `input`, `expected`, `label`.
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

#' List available reference dataset names
#'
#' @return Character vector.
#' @export
reference_datasets <- function() {
  c("injection_basic", "pii_basic", "secrets_basic")
}
