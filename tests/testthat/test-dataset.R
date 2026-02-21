test_that("eval_dataset creates correct structure", {
  ds <- eval_dataset(name = "test")
  expect_s3_class(ds, "secureeval_dataset")
  expect_equal(ds$name, "test")
  expect_equal(length(ds$cases), 0)
})

test_that("eval_dataset validates cases", {
  expect_error(eval_dataset(cases = list("not a test case")), "not a")
})

test_that("add_cases adds test cases", {
  ds <- eval_dataset(name = "test")
  tc1 <- test_case("a", "b")
  tc2 <- test_case("c", "d")
  ds2 <- add_cases(ds, tc1, tc2)
  expect_equal(dataset_size(ds2), 2)
})

test_that("add_cases validates input", {
  ds <- eval_dataset()
  expect_error(add_cases(ds, "not a test case"), "not a")
  expect_error(add_cases("not a dataset", test_case("a", "b")), "dataset")
})

test_that("dataset_size returns correct count", {
  ds <- make_simple_dataset()
  expect_equal(dataset_size(ds), 3)
})

test_that("dataset_summary groups by label", {
  ds <- make_simple_dataset()
  s <- dataset_summary(ds)
  expect_equal(s[["echo"]], 1)
  expect_equal(s[["math"]], 1)
  expect_equal(s[["mismatch"]], 1)
})

test_that("save_dataset and load_dataset round-trip", {
  ds <- make_simple_dataset()
  tmp <- tempfile(fileext = ".json")
  on.exit(unlink(tmp))

  save_dataset(ds, tmp)
  expect_true(file.exists(tmp))

  ds2 <- load_dataset(tmp)
  expect_s3_class(ds2, "secureeval_dataset")
  expect_equal(dataset_size(ds2), 3)
  expect_equal(ds2$name, "test-dataset")
  expect_equal(ds2$cases[[1]]$input, "hello")
  expect_equal(ds2$cases[[1]]$expected, "hello")
  expect_equal(ds2$cases[[1]]$label, "echo")
})

test_that("load_dataset errors on missing file", {
  expect_error(load_dataset("/nonexistent/path.json"), "not found")
})

test_that("print.secureeval_dataset runs without error", {
  ds <- make_simple_dataset()
  expect_no_error(capture.output(print(ds), type = "message"))
})
