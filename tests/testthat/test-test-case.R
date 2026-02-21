test_that("test_case creates correct structure", {
  tc <- test_case("input", "expected", label = "test")
  expect_s3_class(tc, "secureeval_test_case")
  expect_equal(tc$input, "input")
  expect_equal(tc$expected, "expected")
  expect_equal(tc$label, "test")
  expect_equal(tc$metadata, list())
})

test_that("test_case accepts various input types", {
  tc1 <- test_case(list(a = 1), TRUE)
  expect_equal(tc1$input, list(a = 1))
  expect_true(tc1$expected)

  tc2 <- test_case(42, 42)
  expect_equal(tc2$input, 42)
})

test_that("test_case validates arguments", {
  expect_error(test_case(), "input")
  expect_error(test_case("x"), "expected")
  expect_error(test_case("x", "y", label = 123), "label")
  expect_error(test_case("x", "y", metadata = "not a list"), "metadata")
})

test_that("is_test_case works", {
  tc <- test_case("a", "b")
  expect_true(is_test_case(tc))
  expect_false(is_test_case(list(input = "a", expected = "b")))
  expect_false(is_test_case(42))
})

test_that("print.secureeval_test_case runs without error", {
  tc <- test_case("hello", "world", label = "greet", metadata = list(source = "test"))
  expect_no_error(capture.output(print(tc), type = "message"))
})
