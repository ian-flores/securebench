test_that("eval_run executes function on all cases", {
  ds <- make_simple_dataset()
  result <- eval_run(identity, ds, list(eval_exact_match()), name = "test-run")
  expect_s3_class(result, "eval_run_result")
  expect_equal(result$n_cases, 3)
  expect_equal(result$name, "test-run")

  # First case: identity("hello") == "hello" -> score 1
  expect_equal(result$case_results[[1]]$scores[["exact_match"]], 1)
  # Third case: identity("foo") != "bar" -> score 0
  expect_equal(result$case_results[[3]]$scores[["exact_match"]], 0)
})

test_that("eval_run handles errors gracefully", {
  ds <- eval_dataset(list(
    test_case("good", "good"),
    test_case("bad", "bad")
  ))
  error_fn <- function(input) {
    if (input == "bad") stop("intentional error")
    input
  }
  result <- eval_run(error_fn, ds, list(eval_exact_match()))

  # Good case should pass
  expect_equal(result$case_results[[1]]$scores[["exact_match"]], 1)
  expect_null(result$case_results[[1]]$error)

  # Error case should score 0 and record error
  expect_equal(result$case_results[[2]]$scores[["exact_match"]], 0)
  expect_equal(result$case_results[[2]]$error, "intentional error")
  expect_null(result$case_results[[2]]$result)
})

test_that("eval_run records timing", {
  ds <- eval_dataset(list(test_case("x", "x")))
  result <- eval_run(identity, ds, list(eval_exact_match()))
  expect_true(result$case_results[[1]]$duration >= 0)
})

test_that("eval_run works with no evaluators", {
  ds <- eval_dataset(list(test_case("x", "x")))
  result <- eval_run(identity, ds)
  expect_equal(length(result$case_results[[1]]$scores), 0)
})

test_that("eval_run validates arguments", {
  ds <- make_simple_dataset()
  expect_error(eval_run("not a function", ds), "function")
  expect_error(eval_run(identity, "not a dataset"), "dataset")
  expect_error(eval_run(identity, ds, evaluators = list("not evaluator")), "evaluator")
})

test_that("is_eval_run_result works", {
  ds <- eval_dataset(list(test_case("x", "x")))
  result <- eval_run(identity, ds)
  expect_true(is_eval_run_result(result))
  expect_false(is_eval_run_result(list()))
})

test_that("print.eval_run_result runs without error", {
  ds <- make_simple_dataset()
  result <- eval_run(identity, ds, list(eval_exact_match()), name = "test")
  expect_no_error(capture.output(print(result), type = "message"))
})
