test_that("guardrail_eval runs correctly with function guardrail", {
  data <- make_guardrail_data()
  result <- guardrail_eval(simple_guardrail, data)
  expect_true(S7::S7_inherits(result, guardrail_eval_result_class))
  expect_equal(length(result@results), 4)

  expect_true(result@results[[1]]$pass)   # "normal text" -> should pass
  expect_true(result@results[[2]]$pass)   # "safe input" -> should pass
  expect_false(result@results[[3]]$pass)  # "DROP TABLE" -> should block
  expect_false(result@results[[4]]$pass)  # "rm -rf" -> should block
})

test_that("guardrail_metrics computes correctly for perfect guardrail", {
  data <- make_guardrail_data()
  result <- guardrail_eval(simple_guardrail, data)
  m <- guardrail_metrics(result)

  expect_equal(m$true_positives, 2)
  expect_equal(m$true_negatives, 2)
  expect_equal(m$false_positives, 0)
  expect_equal(m$false_negatives, 0)
  expect_equal(m$precision, 1.0)
  expect_equal(m$recall, 1.0)
  expect_equal(m$f1, 1.0)
  expect_equal(m$accuracy, 1.0)
})

test_that("guardrail_metrics handles imperfect guardrail", {
  block_all <- function(text) FALSE
  data <- make_guardrail_data()
  result <- guardrail_eval(block_all, data)
  m <- guardrail_metrics(result)

  expect_equal(m$true_positives, 2)
  expect_equal(m$true_negatives, 0)
  expect_equal(m$false_positives, 2)
  expect_equal(m$false_negatives, 0)
  expect_equal(m$precision, 0.5)
  expect_equal(m$recall, 1.0)
  expect_equal(m$accuracy, 0.5)
})

test_that("guardrail_metrics handles all-pass guardrail", {
  pass_all <- function(text) TRUE
  data <- make_guardrail_data()
  result <- guardrail_eval(pass_all, data)
  m <- guardrail_metrics(result)

  expect_equal(m$true_positives, 0)
  expect_equal(m$true_negatives, 2)
  expect_equal(m$false_positives, 0)
  expect_equal(m$false_negatives, 2)
  expect_true(is.na(m$precision))
  expect_equal(m$recall, 0)
  expect_equal(m$accuracy, 0.5)
})

test_that("guardrail_confusion returns correct structure", {
  data <- make_guardrail_data()
  result <- guardrail_eval(simple_guardrail, data)
  cm <- guardrail_confusion(result)

  expect_true(is.matrix(cm))
  expect_equal(nrow(cm), 2)
  expect_equal(ncol(cm), 2)
  expect_equal(dimnames(cm)$predicted, c("blocked", "passed"))
  expect_equal(dimnames(cm)$actual, c("should_block", "should_pass"))
})

test_that("guardrail_eval handles errors in guardrail function", {
  error_guardrail <- function(text) {
    if (grepl("error", text)) stop("boom")
    TRUE
  }
  data <- data.frame(
    input = c("normal", "trigger error"),
    expected = c(TRUE, FALSE),
    stringsAsFactors = FALSE
  )
  result <- guardrail_eval(error_guardrail, data)
  expect_true(result@results[[1]]$pass)
  expect_false(result@results[[2]]$pass)
})

test_that("guardrail_eval validates input", {
  expect_error(guardrail_eval(identity, "not a data.frame"), "data.frame")
  expect_error(guardrail_eval(identity, data.frame(x = 1)), "input.*expected")
})

test_that("guardrail_compare works correctly", {
  data <- make_guardrail_data()
  result1 <- guardrail_eval(simple_guardrail, data)
  result2 <- guardrail_eval(function(x) TRUE, data)  # passes everything

  cmp <- guardrail_compare(result1, result2)
  expect_true(is.list(cmp))
  expect_true("delta_f1" %in% names(cmp))
  expect_true("improved" %in% names(cmp))
  expect_true("regressed" %in% names(cmp))
})

test_that("print.guardrail_eval_result runs without error", {
  data <- make_guardrail_data()
  result <- guardrail_eval(simple_guardrail, data)
  expect_no_error(capture.output(print(result), type = "message"))
})
