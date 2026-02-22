test_that("as_vitals_scorer creates a working scorer function", {
  my_guard <- function(text) !grepl("DROP TABLE", text, fixed = TRUE)
  scorer <- as_vitals_scorer(my_guard)

  expect_true(is.function(scorer))
  expect_equal(scorer("safe query", TRUE), 1)   # correct pass
  expect_equal(scorer("DROP TABLE x", FALSE), 1) # correct block
  expect_equal(scorer("DROP TABLE x", TRUE), 0)  # wrong: expected pass, got block
  expect_equal(scorer("safe query", FALSE), 0)   # wrong: expected block, got pass
})

test_that("as_vitals_scorer handles errors gracefully", {
  error_guard <- function(text) stop("boom")
  scorer <- as_vitals_scorer(error_guard)
  # Error = treated as block (FALSE), so if expected=FALSE it's correct
  expect_equal(scorer("anything", FALSE), 1)
  expect_equal(scorer("anything", TRUE), 0)
})

test_that("as_vitals_scorer validates input", {
  expect_error(as_vitals_scorer("not a function"), "function")
})
