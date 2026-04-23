test_that("reference_datasets() lists the expected names", {
  names <- reference_datasets()
  expect_setequal(names, c("injection_basic", "pii_basic", "secrets_basic"))
})

test_that("load_reference() returns a well-shaped data.frame for each dataset", {
  for (name in reference_datasets()) {
    df <- load_reference(name)
    expect_s3_class(df, "data.frame")
    expect_named(df, c("input", "expected", "label"), ignore.order = TRUE)
    expect_type(df$input, "character")
    expect_type(df$expected, "logical")
    expect_type(df$label, "character")
    expect_gt(nrow(df), 20L)
    # Each dataset should contain both positive and negative cases so
    # precision/recall/F1 are computable out of the box.
    expect_true(any(df$expected))
    expect_true(any(!df$expected))
  }
})

test_that("load_reference() rejects unknown names", {
  expect_error(load_reference("does_not_exist"), "Unknown reference dataset")
  expect_error(load_reference(c("a", "b")), "single character string")
})
