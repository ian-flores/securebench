#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @import S7
#' @importFrom rlang abort warn inform
#' @importFrom rlang %||%
#' @importFrom cli cli_abort cli_warn cli_text cli_rule cli_ul cli_li cli_end
## usethis namespace: end
NULL

# OpenTelemetry tracer name for this package. The otel package looks up
# this variable to name the tracer used for spans emitted by securebench.
otel_tracer_name <- "com.github.ian-flores.securebench"
