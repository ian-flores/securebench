test_that("guardrail_report console format runs without error", {
  data <- make_guardrail_data()
  result <- guardrail_eval(simple_guardrail, data)
  expect_no_error(capture.output(guardrail_report(result, format = "console"), type = "message"))
})

test_that("guardrail_report data.frame format returns correct structure", {
  data <- make_guardrail_data()
  result <- guardrail_eval(simple_guardrail, data)
  df <- guardrail_report(result, format = "data.frame")

  expect_s3_class(df, "data.frame")
  expect_true("input" %in% names(df))
  expect_true("expected_pass" %in% names(df))
  expect_true("actual_pass" %in% names(df))
  expect_true("correct" %in% names(df))
  expect_equal(nrow(df), 4)
  expect_true(all(df$correct))
})
