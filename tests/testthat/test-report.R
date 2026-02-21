test_that("eval_report console format runs without error", {
  ds <- make_simple_dataset()
  result <- eval_run(identity, ds, list(eval_exact_match()), name = "report-test")
  expect_no_error(capture.output(eval_report(result, format = "console"), type = "message"))
})

test_that("eval_report data.frame format returns correct structure", {
  ds <- make_simple_dataset()
  result <- eval_run(identity, ds, list(eval_exact_match()), name = "df-test")
  df <- eval_report(result, format = "data.frame")

  expect_s3_class(df, "data.frame")
  expect_true("input" %in% names(df))
  expect_true("expected" %in% names(df))
  expect_true("result" %in% names(df))
  expect_true("score" %in% names(df))
  expect_true("evaluator" %in% names(df))
  expect_true("label" %in% names(df))
  expect_true("duration" %in% names(df))
  expect_true("error" %in% names(df))
  expect_equal(nrow(df), 3) # 3 cases x 1 evaluator
})

test_that("eval_report data.frame handles multiple evaluators", {
  ds <- eval_dataset(list(test_case("a", "a"), test_case("b", "b")))
  result <- eval_run(identity, ds, list(eval_exact_match(), eval_contains()))
  df <- eval_report(result, format = "data.frame")
  expect_equal(nrow(df), 4) # 2 cases x 2 evaluators
})

test_that("eval_report data.frame handles errors", {
  ds <- eval_dataset(list(test_case("ok", "ok"), test_case("bad", "bad")))
  result <- eval_run(function(x) { if (x == "bad") stop("err"); x }, ds, list(eval_exact_match()))
  df <- eval_report(result, format = "data.frame")
  expect_true(is.na(df$error[1]))
  expect_equal(df$error[2], "err")
})

test_that("guardrail_report console format runs without error", {
  ds <- make_guardrail_dataset()
  result <- eval_guardrail(simple_guardrail, ds)
  expect_no_error(capture.output(guardrail_report(result, format = "console"), type = "message"))
})

test_that("guardrail_report data.frame format returns correct structure", {
  ds <- make_guardrail_dataset()
  result <- eval_guardrail(simple_guardrail, ds)
  df <- guardrail_report(result, format = "data.frame")

  expect_s3_class(df, "data.frame")
  expect_true("input" %in% names(df))
  expect_true("expected_pass" %in% names(df))
  expect_true("actual_pass" %in% names(df))
  expect_true("correct" %in% names(df))
  expect_equal(nrow(df), 4)
  # All should be correct for our perfect guardrail
  expect_true(all(df$correct))
})
