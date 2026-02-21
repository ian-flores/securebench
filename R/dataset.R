#' Create an evaluation dataset
#'
#' A dataset is a named collection of test cases.
#'
#' @param cases A list of `secureeval_test_case` objects.
#' @param name A name for the dataset.
#' @param description A description of the dataset.
#' @return An object of class `secureeval_dataset`.
#' @export
#' @examples
#' ds <- eval_dataset(
#'   cases = list(test_case("2+2", "4", label = "math")),
#'   name = "basic-math"
#' )
#' ds
eval_dataset <- function(cases = list(), name = "", description = "") {
  if (!is.list(cases)) {
    cli_abort("{.arg cases} must be a list.")
  }
  for (i in seq_along(cases)) {
    if (!is_test_case(cases[[i]])) {
      cli_abort("Element {i} of {.arg cases} is not a {.cls secureeval_test_case}.")
    }
  }
  if (!is.character(name) || length(name) != 1) {
    cli_abort("{.arg name} must be a single character string.")
  }
  if (!is.character(description) || length(description) != 1) {
    cli_abort("{.arg description} must be a single character string.")
  }
  structure(
    list(
      cases = cases,
      name = name,
      description = description
    ),
    class = "secureeval_dataset"
  )
}

#' Add test cases to a dataset
#'
#' @param dataset A `secureeval_dataset` object.
#' @param ... One or more `secureeval_test_case` objects to add.
#' @return A new `secureeval_dataset` with the additional cases.
#' @export
add_cases <- function(dataset, ...) {
  if (!inherits(dataset, "secureeval_dataset")) {
    cli_abort("{.arg dataset} must be a {.cls secureeval_dataset}.")
  }
  new_cases <- list(...)
  for (i in seq_along(new_cases)) {
    if (!is_test_case(new_cases[[i]])) {
      cli_abort("Argument {i} is not a {.cls secureeval_test_case}.")
    }
  }
  dataset$cases <- c(dataset$cases, new_cases)
  dataset
}

#' Get the number of cases in a dataset
#'
#' @param dataset A `secureeval_dataset` object.
#' @return An integer giving the number of test cases.
#' @export
dataset_size <- function(dataset) {
  if (!inherits(dataset, "secureeval_dataset")) {
    cli_abort("{.arg dataset} must be a {.cls secureeval_dataset}.")
  }
  length(dataset$cases)
}

#' Save a dataset to JSON
#'
#' @param dataset A `secureeval_dataset` object.
#' @param path File path to save to.
#' @return `path` invisibly.
#' @export
save_dataset <- function(dataset, path) {
  if (!inherits(dataset, "secureeval_dataset")) {
    cli_abort("{.arg dataset} must be a {.cls secureeval_dataset}.")
  }
  serializable <- list(
    name = dataset$name,
    description = dataset$description,
    cases = lapply(dataset$cases, function(tc) {
      list(
        input = tc$input,
        expected = tc$expected,
        label = tc$label,
        metadata = tc$metadata
      )
    })
  )
  json <- toJSON(serializable, auto_unbox = TRUE, pretty = TRUE, null = "null")
  writeLines(json, path)
  invisible(path)
}

#' Load a dataset from JSON
#'
#' @param path File path to load from.
#' @return A `secureeval_dataset` object.
#' @export
load_dataset <- function(path) {
  if (!file.exists(path)) {
    cli_abort("File not found: {.file {path}}")
  }
  data <- fromJSON(path, simplifyVector = FALSE)
  cases <- lapply(data$cases, function(tc) {
    test_case(
      input = tc$input,
      expected = tc$expected,
      label = tc$label,
      metadata = if (is.null(tc$metadata)) list() else tc$metadata
    )
  })
  eval_dataset(
    cases = cases,
    name = data$name %||% "",
    description = data$description %||% ""
  )
}

#' Summarize a dataset by label
#'
#' @param dataset A `secureeval_dataset` object.
#' @return A named list with counts per label.
#' @export
dataset_summary <- function(dataset) {
  if (!inherits(dataset, "secureeval_dataset")) {
    cli_abort("{.arg dataset} must be a {.cls secureeval_dataset}.")
  }
  labels <- vapply(dataset$cases, function(tc) {
    if (is.null(tc$label)) "(unlabeled)" else tc$label
  }, character(1))
  as.list(table(labels))
}

#' @export
print.secureeval_dataset <- function(x, ...) {
  cli_rule("Eval Dataset: {x$name}")
  if (nzchar(x$description)) {
    cli_text(x$description)
  }
  cli_text("{length(x$cases)} test case(s)")
  summary <- dataset_summary(x)
  if (length(summary) > 0) {
    cli_text("Labels:")
    ul <- cli_ul()
    for (lbl in names(summary)) {
      cli_li("{lbl}: {summary[[lbl]]}")
    }
    cli_end(ul)
  }
  invisible(x)
}
