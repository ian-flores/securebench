# OpenTelemetry tracing tests
# otel is a soft dependency; otelsdk provides an in-memory tracer provider
# for recording spans in tests.

# Record spans emitted while evaluating `expr`. Returns the otelsdk record
# (a list with $value and $traces, where $traces is keyed by span name).
record_spans <- function(expr) {
  otelsdk::with_otel_record(expr, what = "traces")
}

span_event_names <- function(span) {
  vapply(span$events, function(e) e$name, character(1))
}

test_that("guardrail_eval emits span when tracing enabled", {
  skip_if_not_installed("otel")
  skip_if_not_installed("otelsdk")

  data <- make_guardrail_data()
  rec <- record_spans(guardrail_eval(simple_guardrail, data))

  expect_true(S7::S7_inherits(rec$value, guardrail_eval_result_class))
  expect_true("securebench::guardrail_eval" %in% names(rec$traces))
  span <- rec$traces[["securebench::guardrail_eval"]]
  expect_true("eval.complete" %in% span_event_names(span))
})

test_that("guardrail_eval works without tracing", {
  data <- data.frame(
    input = c("Hello"),
    expected = c(TRUE),
    stringsAsFactors = FALSE
  )

  result <- guardrail_eval(simple_guardrail, data)
  expect_true(S7::S7_inherits(result, guardrail_eval_result_class))
})

test_that("guardrail_metrics emits span when tracing enabled", {
  skip_if_not_installed("otel")
  skip_if_not_installed("otelsdk")

  data <- make_guardrail_data()
  eval_result <- guardrail_eval(simple_guardrail, data)

  rec <- record_spans(guardrail_metrics(eval_result))

  expect_true(is.list(rec$value))
  expect_true("precision" %in% names(rec$value))
  expect_true("securebench::guardrail_metrics" %in% names(rec$traces))
  span <- rec$traces[["securebench::guardrail_metrics"]]
  expect_true("metrics.complete" %in% span_event_names(span))
})

test_that("guardrail_compare emits span when tracing enabled", {
  skip_if_not_installed("otel")
  skip_if_not_installed("otelsdk")

  data <- make_guardrail_data()
  r1 <- guardrail_eval(simple_guardrail, data)
  r2 <- guardrail_eval(function(x) TRUE, data)

  rec <- record_spans(guardrail_compare(r1, r2))

  expect_true(is.list(rec$value))
  expect_true("improved" %in% names(rec$value))
  expect_true("securebench::guardrail_compare" %in% names(rec$traces))
})

test_that("benchmark_guardrail emits span when tracing enabled", {
  skip_if_not_installed("otel")
  skip_if_not_installed("otelsdk")

  rec <- record_spans(
    benchmark_guardrail(simple_guardrail,
      positive_cases = c("DROP TABLE x"),
      negative_cases = c("Hello world")
    )
  )

  expect_true(is.list(rec$value))
  expect_true("securebench::benchmark_guardrail" %in% names(rec$traces))
  # nested spans from the wrapped eval/metrics calls are recorded too
  expect_true("securebench::guardrail_eval" %in% names(rec$traces))
})

test_that("benchmark_pipeline emits span when tracing enabled", {
  skip_if_not_installed("otel")
  skip_if_not_installed("otelsdk")

  data <- make_guardrail_data()

  rec <- record_spans(benchmark_pipeline(simple_guardrail, data))

  expect_true(S7::S7_inherits(rec$value, guardrail_eval_result_class))
  expect_true("securebench::benchmark_pipeline" %in% names(rec$traces))
})

test_that(".trace_active returns FALSE when no tracer provider is configured", {
  # Outside with_otel_record() there is no SDK tracer provider, so
  # tracing is disabled (even if otel is installed)
  expect_false(.trace_active())
})

test_that("all functions work with tracing disabled", {
  # These should all work fine with no tracer provider configured
  data <- make_guardrail_data()

  result <- guardrail_eval(simple_guardrail, data)
  expect_true(S7::S7_inherits(result, guardrail_eval_result_class))

  m <- guardrail_metrics(result)
  expect_equal(m$precision, 1.0)

  r2 <- guardrail_eval(function(x) TRUE, data)
  cmp <- guardrail_compare(result, r2)
  expect_true(is.list(cmp))

  bm <- benchmark_guardrail(simple_guardrail,
    positive_cases = c("DROP TABLE x"),
    negative_cases = c("Hello")
  )
  expect_true(is.list(bm))

  bp <- benchmark_pipeline(simple_guardrail, data)
  expect_true(S7::S7_inherits(bp, guardrail_eval_result_class))
})
