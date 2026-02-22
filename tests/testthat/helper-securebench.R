# Shared test helpers for securebench tests

make_guardrail_data <- function() {
  data.frame(
    input = c("normal text", "safe input", "DROP TABLE users", "rm -rf /"),
    expected = c(TRUE, TRUE, FALSE, FALSE),
    label = c("benign", "benign", "injection", "injection"),
    stringsAsFactors = FALSE
  )
}

simple_guardrail <- function(text) {
  !grepl("DROP TABLE|rm -rf", text)
}
