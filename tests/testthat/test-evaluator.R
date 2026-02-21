test_that("evaluator creates correct structure", {
  e <- evaluator("test", function(r, e) 1)
  expect_s3_class(e, "secureeval_evaluator")
  expect_equal(e$name, "test")
  expect_true(is.function(e$score_fn))
})

test_that("evaluator validates arguments", {
  expect_error(evaluator("", function(r, e) 1), "non-empty")
  expect_error(evaluator("test", "not a function"), "function")
  expect_error(evaluator(123, function(r, e) 1), "character")
})

test_that("is_evaluator works", {
  e <- evaluator("test", function(r, e) 1)
  expect_true(is_evaluator(e))
  expect_false(is_evaluator(list(name = "test")))
})

test_that("print.secureeval_evaluator runs without error", {
  e <- evaluator("test", function(r, e) 1, description = "A test evaluator")
  expect_no_error(capture.output(print(e), type = "message"))
})
