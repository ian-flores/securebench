test_that("benchmark_guardrail returns correct metrics", {
  my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)

  metrics <- benchmark_guardrail(
    my_guard,
    positive_cases = c("DROP TABLE users", "SELECT 1; DROP TABLE x"),
    negative_cases = c("SELECT * FROM users", "Hello world")
  )

  expect_true(is.list(metrics))
  expect_equal(metrics$true_positives, 2)
  expect_equal(metrics$true_negatives, 2)
  expect_equal(metrics$precision, 1.0)
  expect_equal(metrics$recall, 1.0)
})

test_that("benchmark_guardrail validates arguments", {
  expect_error(benchmark_guardrail(identity, positive_cases = 123, negative_cases = "a"), "character")
  expect_error(benchmark_guardrail(identity, positive_cases = "a", negative_cases = 123), "character")
})

test_that("benchmark_pipeline works with function", {
  ds <- eval_dataset(list(
    test_case("hello", "hello"),
    test_case("world", "world")
  ))
  result <- benchmark_pipeline(identity, ds, list(eval_exact_match()))
  expect_s3_class(result, "eval_run_result")
  expect_equal(result$n_cases, 2)
})

test_that("benchmark_pipeline works with list-based pipeline", {
  pipeline <- list(run = function(x) paste0(x, "!"))
  ds <- eval_dataset(list(test_case("hi", "hi!")))
  result <- benchmark_pipeline(pipeline, ds, list(eval_exact_match()))
  expect_equal(result$case_results[[1]]$scores[["exact_match"]], 1)
})

test_that("benchmark_pipeline validates arguments", {
  ds <- eval_dataset(list(test_case("x", "x")))
  expect_error(benchmark_pipeline("not a pipeline", ds, list()), "function")
})
