test_that("eval_score computes correct mean", {
  ds <- make_simple_dataset()
  result <- eval_run(identity, ds, list(eval_exact_match()))
  scores <- eval_score(result)

  # 1/3 cases match (hello == hello), so mean = 1/3
  expect_equal(scores$mean_score, 1/3, tolerance = 0.001)
})

test_that("eval_score computes pass_rate", {
  ds <- make_simple_dataset()
  result <- eval_run(identity, ds, list(eval_exact_match()))
  scores <- eval_score(result)

  # Only 1 of 3 scores >= 0.5
  expect_equal(scores$pass_rate, 1/3, tolerance = 0.001)
})

test_that("eval_score by_evaluator works", {
  ds <- eval_dataset(list(
    test_case("hello", "hello"),
    test_case("world", "world")
  ))
  result <- eval_run(identity, ds, list(eval_exact_match(), eval_contains()))
  scores <- eval_score(result)

  expect_equal(scores$by_evaluator[["exact_match"]], 1.0)
  expect_equal(scores$by_evaluator[["contains"]], 1.0)
})

test_that("eval_score by_label works", {
  ds <- make_simple_dataset()
  result <- eval_run(identity, ds, list(eval_exact_match()))
  scores <- eval_score(result)

  expect_equal(scores$by_label[["echo"]], 1.0)
  expect_equal(scores$by_label[["math"]], 0.0)
  expect_equal(scores$by_label[["mismatch"]], 0.0)
})

test_that("eval_score total_time is non-negative", {
  ds <- make_simple_dataset()
  result <- eval_run(identity, ds, list(eval_exact_match()))
  scores <- eval_score(result)
  expect_true(scores$total_time >= 0)
})

test_that("eval_compare detects improvement", {
  ds <- eval_dataset(list(
    test_case("hello", "hello"),
    test_case("world", "world")
  ))
  # Run 1: function that always returns wrong answer
  r1 <- eval_run(function(x) "wrong", ds, list(eval_exact_match()))
  # Run 2: identity (correct)
  r2 <- eval_run(identity, ds, list(eval_exact_match()))

  comp <- eval_compare(r1, r2)
  expect_equal(comp$delta_score, 1.0)
  expect_equal(comp$improved, 2)
  expect_equal(comp$regressed, 0)
  expect_equal(comp$unchanged, 0)
})

test_that("eval_compare detects regression", {
  ds <- eval_dataset(list(
    test_case("hello", "hello")
  ))
  r1 <- eval_run(identity, ds, list(eval_exact_match()))
  r2 <- eval_run(function(x) "wrong", ds, list(eval_exact_match()))

  comp <- eval_compare(r1, r2)
  expect_equal(comp$delta_score, -1.0)
  expect_equal(comp$regressed, 1)
})

test_that("eval_compare validates arguments", {
  expect_error(eval_compare("not result", "not result"), "eval_run_result")
})
