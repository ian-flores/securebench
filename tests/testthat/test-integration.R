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
  data <- data.frame(
    input = c("hello", "world"),
    expected = c(TRUE, TRUE),
    stringsAsFactors = FALSE
  )
  result <- benchmark_pipeline(identity, data)
  expect_true(S7::S7_inherits(result, guardrail_eval_result_class))
  expect_equal(length(result@results), 2)
})

test_that("benchmark_pipeline works with list-based pipeline", {
  pipeline <- list(run = function(x) TRUE)
  data <- data.frame(
    input = c("hi"),
    expected = c(TRUE),
    stringsAsFactors = FALSE
  )
  result <- benchmark_pipeline(pipeline, data)
  expect_true(result@results[[1]]$pass)
})

test_that("benchmark_pipeline validates arguments", {
  data <- data.frame(input = "x", expected = TRUE, stringsAsFactors = FALSE)
  expect_error(benchmark_pipeline("not a pipeline", data), "function")
})
