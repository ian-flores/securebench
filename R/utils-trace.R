# Internal tracing helpers -- not exported
# otel (OpenTelemetry) is a soft dependency (Suggests only)

#' Check if OpenTelemetry tracing is enabled
#' @return Logical scalar.
#' @noRd
.trace_active <- function() {
  requireNamespace("otel", quietly = TRUE) && otel::is_tracing_enabled()
}

#' Evaluate an expression inside an active OpenTelemetry span
#'
#' Starts a span that ends automatically when this function returns.
#' If tracing is disabled (or otel is not installed), the expression is
#' evaluated without a span.
#'
#' @param name Span name.
#' @param expr Expression to evaluate.
#' @param attributes Optional named list of span attributes.
#' @return The value of `expr`.
#' @noRd
.with_span <- function(name, expr, attributes = NULL) {
  if (.trace_active()) {
    otel::start_local_active_span(
      name,
      attributes = if (length(attributes)) otel::as_attributes(attributes)
    )
  }
  expr
}

#' Emit an event on the active span (if tracing is enabled)
#' @param name Event name.
#' @param data Named list of event data.
#' @return Invisible `NULL`.
#' @noRd
.span_event <- function(name, data = list()) {
  if (.trace_active()) {
    span <- otel::get_active_span()
    if (!is.null(span)) {
      span$add_event(
        name,
        attributes = if (length(data)) otel::as_attributes(data)
      )
    }
  }
  invisible(NULL)
}
