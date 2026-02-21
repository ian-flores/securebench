test_that("eval_exact_match scores correctly", {
  e <- eval_exact_match()
  expect_equal(e$score_fn("hello", "hello"), 1)
  expect_equal(e$score_fn("hello", "world"), 0)
  expect_equal(e$score_fn(42, 42), 1)
  expect_equal(e$score_fn(42, 43), 0)
})

test_that("eval_contains scores correctly", {
  e <- eval_contains()
  expect_equal(e$score_fn("hello world", "world"), 1)
  expect_equal(e$score_fn("hello world", "xyz"), 0)
  expect_equal(e$score_fn("Hello", "hello"), 0) # case sensitive

  e2 <- eval_contains(case_sensitive = FALSE)
  expect_equal(e2$score_fn("Hello", "hello"), 1)
})

test_that("eval_regex_match scores correctly", {
  e <- eval_regex_match()
  expect_equal(e$score_fn("hello world", "^hello"), 1)
  expect_equal(e$score_fn("hello world", "^world"), 0)
  expect_equal(e$score_fn("abc123", "\\d+"), 1)
})

test_that("eval_numeric_close scores correctly", {
  e <- eval_numeric_close(tolerance = 0.1)
  expect_equal(e$score_fn(3.14, 3.14), 1)
  expect_equal(e$score_fn(3.14, 3.20), 1)
  expect_equal(e$score_fn(3.14, 3.30), 0)
  expect_equal(e$score_fn("abc", 3.14), 0) # NA conversion
})

test_that("eval_custom wraps function correctly", {
  e <- eval_custom(function(r, e) if (nchar(r) > 3) 1 else 0)
  expect_equal(e$score_fn("hello", ""), 1)
  expect_equal(e$score_fn("hi", ""), 0)
  expect_equal(e$name, "custom")
})

test_that("eval_custom validates input", {
  expect_error(eval_custom("not a function"), "function")
})
