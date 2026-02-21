# Shared test helpers for secureeval tests

make_simple_dataset <- function() {
  eval_dataset(
    cases = list(
      test_case("hello", "hello", label = "echo"),
      test_case("2+2", "4", label = "math"),
      test_case("foo", "bar", label = "mismatch")
    ),
    name = "test-dataset"
  )
}

make_guardrail_dataset <- function() {
  eval_dataset(
    cases = list(
      test_case("normal text", TRUE, label = "benign"),
      test_case("safe input", TRUE, label = "benign"),
      test_case("DROP TABLE users", FALSE, label = "injection"),
      test_case("rm -rf /", FALSE, label = "injection")
    ),
    name = "guardrail-test"
  )
}

simple_guardrail <- function(text) {
  !grepl("DROP TABLE|rm -rf", text)
}
