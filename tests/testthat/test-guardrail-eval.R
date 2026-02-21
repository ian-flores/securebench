test_that("eval_guardrail runs correctly with function guardrail", {
  ds <- make_guardrail_dataset()
  result <- eval_guardrail(simple_guardrail, ds)
  expect_s3_class(result, "guardrail_eval_result")
  expect_equal(length(result$results), 4)

  # Check individual results
  expect_true(result$results[[1]]$pass)   # "normal text" -> should pass
  expect_true(result$results[[2]]$pass)   # "safe input" -> should pass
  expect_false(result$results[[3]]$pass)  # "DROP TABLE" -> should block
  expect_false(result$results[[4]]$pass)  # "rm -rf" -> should block
})

test_that("guardrail_metrics computes correctly for perfect guardrail", {
  ds <- make_guardrail_dataset()
  result <- eval_guardrail(simple_guardrail, ds)
  m <- guardrail_metrics(result)

  expect_equal(m$true_positives, 2)   # correctly blocked
  expect_equal(m$true_negatives, 2)   # correctly allowed
  expect_equal(m$false_positives, 0)  # wrongly blocked
  expect_equal(m$false_negatives, 0)  # wrongly allowed
  expect_equal(m$precision, 1.0)
  expect_equal(m$recall, 1.0)
  expect_equal(m$f1, 1.0)
  expect_equal(m$accuracy, 1.0)
})

test_that("guardrail_metrics handles imperfect guardrail", {
  # Guardrail that blocks everything
  block_all <- function(text) FALSE
  ds <- make_guardrail_dataset()
  result <- eval_guardrail(block_all, ds)
  m <- guardrail_metrics(result)

  expect_equal(m$true_positives, 2)   # correctly blocked injections
  expect_equal(m$true_negatives, 0)   # no correctly allowed

  expect_equal(m$false_positives, 2)  # wrongly blocked benign
  expect_equal(m$false_negatives, 0)  # no wrongly allowed
  expect_equal(m$precision, 0.5)
  expect_equal(m$recall, 1.0)
  expect_equal(m$accuracy, 0.5)
})

test_that("guardrail_metrics handles all-pass guardrail", {
  # Guardrail that passes everything
  pass_all <- function(text) TRUE
  ds <- make_guardrail_dataset()
  result <- eval_guardrail(pass_all, ds)
  m <- guardrail_metrics(result)

  expect_equal(m$true_positives, 0)
  expect_equal(m$true_negatives, 2)
  expect_equal(m$false_positives, 0)
  expect_equal(m$false_negatives, 2)
  expect_true(is.na(m$precision)) # 0/(0+0)
  expect_equal(m$recall, 0)
  expect_equal(m$accuracy, 0.5)
})

test_that("confusion_matrix returns correct structure", {
  ds <- make_guardrail_dataset()
  result <- eval_guardrail(simple_guardrail, ds)
  cm <- confusion_matrix(result)

  expect_true(is.matrix(cm))
  expect_equal(nrow(cm), 2)
  expect_equal(ncol(cm), 2)
  expect_equal(dimnames(cm)$predicted, c("blocked", "passed"))
  expect_equal(dimnames(cm)$actual, c("should_block", "should_pass"))
})

test_that("eval_guardrail handles errors in guardrail function", {
  error_guardrail <- function(text) {
    if (grepl("error", text)) stop("boom")
    TRUE
  }
  ds <- eval_dataset(list(
    test_case("normal", TRUE),
    test_case("trigger error", FALSE)
  ))
  result <- eval_guardrail(error_guardrail, ds)
  # Error case should be treated as blocked (pass = FALSE)
  expect_true(result$results[[1]]$pass)
  expect_false(result$results[[2]]$pass)
})

test_that("print.guardrail_eval_result runs without error", {
  ds <- make_guardrail_dataset()
  result <- eval_guardrail(simple_guardrail, ds)
  expect_no_error(capture.output(print(result), type = "message"))
})
