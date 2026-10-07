# Getting started with securebench

## What securebench is for

securebench measures how well a guardrail does its job. You give it a
guardrail and some labeled examples, and it tells you how many attacks
the guardrail caught and how many harmless inputs it blocked by mistake.
It’s meant for security checks: prompt injection, dangerous code, leaked
personal data and secrets, and comparing two versions of a guardrail
such as a [secureguard](https://github.com/ian-flores/secureguard)
pipeline.

It is not a general LLM evaluation framework. For tasks, solvers and
model-graded scoring, use the tidyverse’s
[vitals](https://vitals.tidyverse.org/) package. vitals has no security
datasets, which is the gap securebench fills.

## Why measure a guardrail?

A guardrail makes a yes-or-no call on every input: let it through or
block it. It can be wrong in two ways.

If it’s too strict, it blocks normal requests. A support bot that treats
“how do I delete my account?” as a SQL injection attack isn’t protecting
anyone. It just annoys users, and sooner or later they stop using it or
find a way around it. These mistakes are false alarms.

If it’s too loose, attacks get through. Prompt injections reach the
model, SQL payloads reach the database, and malicious code runs in your
sandbox. These are missed attacks. In security work they’re usually the
worse mistake, since one missed attack can do real damage while a false
alarm mostly costs someone’s patience.

Measuring tells you how often each mistake happens, instead of guessing.

## Precision, recall and F1

Precision asks: of everything the guardrail blocked, how much was really
an attack? A precision of 0.90 means 9 in 10 blocks were attacks and 1
in 10 was a false alarm.

Recall asks: of all the attacks in the dataset, how many did the
guardrail block? A recall of 0.80 means it caught 80% of attacks and
missed 20%.

F1 combines the two into one number using the harmonic mean, which drags
the score down when either one is low. A guardrail with 0.99 precision
and 0.10 recall gets an F1 of 0.18, where a plain average would give
0.55. So F1 is only high when both precision and recall are.

In security you usually care more about recall than precision, but it
depends on the setting. A sandbox that only you use can put up with more
false alarms than a chatbot your customers talk to.

## The confusion matrix

All of these numbers come from a 2x2 table of what the guardrail did
against what it should have done:

![](data:image/svg+xml;base64,PHN2ZyByb2xlPSJpbWciIGFyaWEtbGFiZWw9IlR3byBieSB0d28gdGFibGU6IGJsb2NrZWQgb3IgcGFzc2VkLCBhZ2FpbnN0IGRhbmdlcm91cyBvciBzYWZlIiB2aWV3Ym94PSIwIDAgNjQwIDI3MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZGVmcz48bWFya2VyIGlkPSJjbS1hcnJvdyIgdmlld2JveD0iMCAwIDEwIDEwIiByZWZ4PSI5IiByZWZ5PSI1IiBtYXJrZXJ3aWR0aD0iNyIgbWFya2VyaGVpZ2h0PSI3IiBvcmllbnQ9ImF1dG8tc3RhcnQtcmV2ZXJzZSI+PHBhdGggZD0iTTEgMUw5IDVMMSA5IiBmaWxsPSJub25lIiBzdHJva2U9IiMyYjFmMTIiIHN0cm9rZS13aWR0aD0iMSIgLz48L21hcmtlcj48cGF0dGVybiBpZD0iY20taGF0Y2giIHdpZHRoPSI2IiBoZWlnaHQ9IjYiIHBhdHRlcm51bml0cz0idXNlclNwYWNlT25Vc2UiIHBhdHRlcm50cmFuc2Zvcm09InJvdGF0ZSg0NSkiPjxsaW5lIHgxPSIwIiB5MT0iMCIgeDI9IjAiIHkyPSI2IiBzdHJva2U9IiNiZjVhMzYiIHN0cm9rZS13aWR0aD0iMC42IiBvcGFjaXR5PSIwLjU1Ij48L2xpbmU+PC9wYXR0ZXJuPjwvZGVmcz48dGV4dCB4PSI0MDAiIHk9IjI2IiBmb250LWZhbWlseT0iU3BhY2UgTW9ubywgdWktbW9ub3NwYWNlLCBtb25vc3BhY2UiIGZvbnQtc2l6ZT0iMTAiIGZpbGw9IiM2YjU2MzgiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZvbnQtd2VpZ2h0PSI0MDAiIGxldHRlci1zcGFjaW5nPSIyIj5XSEFUIFRIRSBJTlBVVCBXQVM8L3RleHQ+PHBhdGggZD0iTTIxMCAzNkg1OTAiIHN0cm9rZT0iI2NkYjQ4YSIgc3Ryb2tlLXdpZHRoPSIwLjc1IiAvPjxwYXRoIGQ9Ik0yMTAgMzJWNDBNNTkwIDMyVjQwIiBzdHJva2U9IiNjZGI0OGEiIHN0cm9rZS13aWR0aD0iMC43NSIgLz48dGV4dCB4PSIzMDUuMCIgeT0iNTgiIGZvbnQtZmFtaWx5PSJTcGFjZSBNb25vLCB1aS1tb25vc3BhY2UsIG1vbm9zcGFjZSIgZm9udC1zaXplPSIxMC41IiBmaWxsPSIjMmIxZjEyIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmb250LXdlaWdodD0iNDAwIiBsZXR0ZXItc3BhY2luZz0iMS4yIj5EQU5HRVJPVVM8L3RleHQ+PHRleHQgeD0iNDk1LjAiIHk9IjU4IiBmb250LWZhbWlseT0iU3BhY2UgTW9ubywgdWktbW9ub3NwYWNlLCBtb25vc3BhY2UiIGZvbnQtc2l6ZT0iMTAuNSIgZmlsbD0iIzJiMWYxMiIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZm9udC13ZWlnaHQ9IjQwMCIgbGV0dGVyLXNwYWNpbmc9IjEuMiI+U0FGRTwvdGV4dD48dGV4dCB4PSI0MCIgeT0iMTYyIiBmb250LWZhbWlseT0iU3BhY2UgTW9ubywgdWktbW9ub3NwYWNlLCBtb25vc3BhY2UiIGZvbnQtc2l6ZT0iMTAiIGZpbGw9IiM2YjU2MzgiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZvbnQtd2VpZ2h0PSI0MDAiIGxldHRlci1zcGFjaW5nPSIyIiB0cmFuc2Zvcm09InJvdGF0ZSgtOTAgNDAgMTYyKSI+V0hBVCBUSEUgR1VBUkRSQUlMIERJRDwvdGV4dD48cGF0aCBkPSJNNTQgNzBWMjU0IiBzdHJva2U9IiNjZGI0OGEiIHN0cm9rZS13aWR0aD0iMC43NSIgLz48cGF0aCBkPSJNNTAgNzBINThNNTAgMjU0SDU4IiBzdHJva2U9IiNjZGI0OGEiIHN0cm9rZS13aWR0aD0iMC43NSIgLz48dGV4dCB4PSIxODgiIHk9IjEyMC4wIiBmb250LWZhbWlseT0iU3BhY2UgTW9ubywgdWktbW9ub3NwYWNlLCBtb25vc3BhY2UiIGZvbnQtc2l6ZT0iMTAuNSIgZmlsbD0iIzJiMWYxMiIgdGV4dC1hbmNob3I9ImVuZCIgZm9udC13ZWlnaHQ9IjQwMCIgbGV0dGVyLXNwYWNpbmc9IjEuMiI+QkxPQ0tFRDwvdGV4dD48dGV4dCB4PSIxODgiIHk9IjIxMi4wIiBmb250LWZhbWlseT0iU3BhY2UgTW9ubywgdWktbW9ub3NwYWNlLCBtb25vc3BhY2UiIGZvbnQtc2l6ZT0iMTAuNSIgZmlsbD0iIzJiMWYxMiIgdGV4dC1hbmNob3I9ImVuZCIgZm9udC13ZWlnaHQ9IjQwMCIgbGV0dGVyLXNwYWNpbmc9IjEuMiI+UEFTU0VEPC90ZXh0PjxyZWN0IHg9IjIxMCIgeT0iNzAiIHdpZHRoPSIxOTAiIGhlaWdodD0iOTIiIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzJiMWYxMiIgc3Ryb2tlLXdpZHRoPSIwLjc1IiAvPjx0ZXh0IHg9IjMwNS4wIiB5PSIxMTMuMCIgZm9udC1mYW1pbHk9IlNwYWNlIE1vbm8sIHVpLW1vbm9zcGFjZSwgbW9ub3NwYWNlIiBmb250LXNpemU9IjExIiBmaWxsPSIjMmIxZjEyIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmb250LXdlaWdodD0iNzAwIiBsZXR0ZXItc3BhY2luZz0iMS4yIj5UUlVFIFBPU0lUSVZFPC90ZXh0Pjx0ZXh0IHg9IjMwNS4wIiB5PSIxMzEuMCIgZm9udC1mYW1pbHk9IlNwYWNlIE1vbm8sIHVpLW1vbm9zcGFjZSwgbW9ub3NwYWNlIiBmb250LXNpemU9IjkuNSIgZmlsbD0iIzZiNTYzOCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZm9udC13ZWlnaHQ9IjQwMCIgbGV0dGVyLXNwYWNpbmc9IjAuNCI+Y2F1Z2h0IGl0PC90ZXh0PjxyZWN0IHg9IjQwMCIgeT0iNzAiIHdpZHRoPSIxOTAiIGhlaWdodD0iOTIiIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzJiMWYxMiIgc3Ryb2tlLXdpZHRoPSIwLjc1IiAvPjx0ZXh0IHg9IjQ5NS4wIiB5PSIxMTMuMCIgZm9udC1mYW1pbHk9IlNwYWNlIE1vbm8sIHVpLW1vbm9zcGFjZSwgbW9ub3NwYWNlIiBmb250LXNpemU9IjExIiBmaWxsPSIjMmIxZjEyIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmb250LXdlaWdodD0iNzAwIiBsZXR0ZXItc3BhY2luZz0iMS4yIj5GQUxTRSBBTEFSTTwvdGV4dD48dGV4dCB4PSI0OTUuMCIgeT0iMTMxLjAiIGZvbnQtZmFtaWx5PSJTcGFjZSBNb25vLCB1aS1tb25vc3BhY2UsIG1vbm9zcGFjZSIgZm9udC1zaXplPSI5LjUiIGZpbGw9IiM2YjU2MzgiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZvbnQtd2VpZ2h0PSI0MDAiIGxldHRlci1zcGFjaW5nPSIwLjQiPmJsb2NrZWQgYSBzYWZlIGlucHV0PC90ZXh0PjxyZWN0IHg9IjIxMCIgeT0iMTYyIiB3aWR0aD0iMTkwIiBoZWlnaHQ9IjkyIiBmaWxsPSJ1cmwoI2NtLWhhdGNoKSIgc3Ryb2tlPSIjYmY1YTM2IiBzdHJva2Utd2lkdGg9IjAuNzUiIC8+PHRleHQgeD0iMzA1LjAiIHk9IjIwNS4wIiBmb250LWZhbWlseT0iU3BhY2UgTW9ubywgdWktbW9ub3NwYWNlLCBtb25vc3BhY2UiIGZvbnQtc2l6ZT0iMTEiIGZpbGw9IiNiZjVhMzYiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZvbnQtd2VpZ2h0PSI3MDAiIGxldHRlci1zcGFjaW5nPSIxLjIiPk1JU1NFRCBBVFRBQ0s8L3RleHQ+PHRleHQgeD0iMzA1LjAiIHk9IjIyMy4wIiBmb250LWZhbWlseT0iU3BhY2UgTW9ubywgdWktbW9ub3NwYWNlLCBtb25vc3BhY2UiIGZvbnQtc2l6ZT0iOS41IiBmaWxsPSIjNmI1NjM4IiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmb250LXdlaWdodD0iNDAwIiBsZXR0ZXItc3BhY2luZz0iMC40Ij50aGUgd29yc3QgY2FzZTwvdGV4dD48cmVjdCB4PSI0MDAiIHk9IjE2MiIgd2lkdGg9IjE5MCIgaGVpZ2h0PSI5MiIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMmIxZjEyIiBzdHJva2Utd2lkdGg9IjAuNzUiIC8+PHRleHQgeD0iNDk1LjAiIHk9IjIwNS4wIiBmb250LWZhbWlseT0iU3BhY2UgTW9ubywgdWktbW9ub3NwYWNlLCBtb25vc3BhY2UiIGZvbnQtc2l6ZT0iMTEiIGZpbGw9IiMyYjFmMTIiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZvbnQtd2VpZ2h0PSI3MDAiIGxldHRlci1zcGFjaW5nPSIxLjIiPlRSVUUgTkVHQVRJVkU8L3RleHQ+PHRleHQgeD0iNDk1LjAiIHk9IjIyMy4wIiBmb250LWZhbWlseT0iU3BhY2UgTW9ubywgdWktbW9ub3NwYWNlLCBtb25vc3BhY2UiIGZvbnQtc2l6ZT0iOS41IiBmaWxsPSIjNmI1NjM4IiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmb250LXdlaWdodD0iNDAwIiBsZXR0ZXItc3BhY2luZz0iMC40Ij5sZXQgaXQgdGhyb3VnaDwvdGV4dD48L3N2Zz4=)

Fig. 1 · What the guardrail did, against what it should have done

Top left: the input was dangerous and the guardrail blocked it. That’s
what you want.

Top right: the input was safe but got blocked. A false alarm.

Bottom left: the input was dangerous and got through. A missed attack,
and the worst case.

Bottom right: the input was safe and got through. Also what you want.

The formulas:

- Precision = True positives / (True positives + False alarms)
- Recall = True positives / (True positives + Missed attacks)
- F1 = 2 \* Precision \* Recall / (Precision + Recall)

## A first benchmark

The quickest way in is
[`benchmark_guardrail()`](https://ian-flores.github.io/securebench/reference/benchmark_guardrail.md).
Give it a guardrail and two vectors: inputs that should be blocked and
inputs that should get through.

``` r

library(securebench)

my_guardrail <- function(text) {
  !grepl("DROP TABLE|rm -rf", text)
}

metrics <- benchmark_guardrail(
  my_guardrail,
  positive_cases = c("DROP TABLE users", "rm -rf /"),
  negative_cases = c("SELECT * FROM users", "Hello world")
)
metrics$precision
metrics$recall
metrics$f1
metrics$accuracy
```

`positive_cases` are the inputs it should block. `negative_cases` are
the ones it should let through. securebench runs the guardrail on each
and computes the four numbers.

## Using a data frame

For bigger test sets, use a data frame with `input` and `expected`
columns. `expected` is `TRUE` when the input is safe and should get
through, and `FALSE` when it’s dangerous and should be blocked:

``` r

data <- data.frame(
  input = c("normal text", "safe query", "DROP TABLE x", "rm -rf /"),
  expected = c(TRUE, TRUE, FALSE, FALSE),
  label = c("benign", "benign", "injection", "injection")
)

result <- guardrail_eval(my_guardrail, data)
m <- guardrail_metrics(result)
cm <- guardrail_confusion(result)
```

The `label` column is optional. It’s worth adding, because it shows you
which kinds of attack a guardrail misses when you look at the report.

If the guardrail throws an error on an input, securebench counts that
input as blocked.

## Reading the numbers

Some rough guidance:

| Metric           | Value      | What it means                         |
|------------------|------------|---------------------------------------|
| Precision = 1.00 | Perfect    | Every block was a real attack         |
| Precision = 0.50 | Worrying   | Half of all blocks were false alarms  |
| Recall = 1.00    | Perfect    | Every attack was caught               |
| Recall = 0.50    | Dangerous  | Half of all attacks got through       |
| F1 = 1.00        | Perfect    | Precision and recall are both perfect |
| F1 \< 0.70       | Needs work | One of the two is weak, or both are   |

High recall with low precision means the guardrail catches everything
but also blocks too many safe inputs. Making the patterns more specific
usually helps. High precision with low recall is the opposite: when it
blocks, it’s right, but it misses a lot. That usually means you need
more patterns.

## Reports

[`guardrail_report()`](https://ian-flores.github.io/securebench/reference/guardrail_report.md)
prints a summary or returns a data frame:

``` r

guardrail_report(result, format = "console")

df <- guardrail_report(result, format = "data.frame")
head(df)
```

The console version is handy while you’re working. The data frame has
one row per case, so you can filter to the failures or group them by
label.

## Comparing two versions

When you change a guardrail, check that the change helped and didn’t
break anything.
[`guardrail_compare()`](https://ian-flores.github.io/securebench/reference/guardrail_compare.md)
takes the old result and the new one:

``` r

improved_guard <- function(text) {
  !grepl("DROP TABLE|rm -rf|DELETE FROM", text)
}

result_v2 <- guardrail_eval(improved_guard, data)
comparison <- guardrail_compare(result, result_v2)
comparison$delta_f1
comparison$improved
comparison$regressed
```

Watch `regressed`. It counts cases the new version gets wrong that the
old one got right. If it’s above zero, the change broke something, and
that could mean an attack the old version blocked now gets through.

## Using a guardrail with vitals

[`as_vitals_scorer()`](https://ian-flores.github.io/securebench/reference/as_vitals_scorer.md)
turns a guardrail into a function that scores one case: 1 if the
guardrail got it right, 0 if not.

``` r

scorer <- as_vitals_scorer(my_guardrail)
scorer("safe query", TRUE)    # 1 (correct)
scorer("DROP TABLE x", FALSE) # 1 (correct)
```

vitals scorers take a task’s whole `samples` data frame rather than one
case at a time, so to use this in a vitals `Task`, call it on each row
from a small wrapper.

## Benchmarking a pipeline

[`benchmark_pipeline()`](https://ian-flores.github.io/securebench/reference/benchmark_pipeline.md)
works like
[`guardrail_eval()`](https://ian-flores.github.io/securebench/reference/guardrail_eval.md),
but also accepts an object with a `$run()` method. Use it when several
checks run in a row and you want to measure them together:

``` r

pipeline <- list(run = function(text) {
  !grepl("DROP TABLE|rm -rf|eval\\(", text)
})

result <- benchmark_pipeline(pipeline, data)
guardrail_metrics(result)
```

A secureguard
[`secure_pipeline()`](https://ian-flores.github.io/secureguard/reference/secure_pipeline.html)
has no `$run()` method. Pass one of its check functions instead, for
example `benchmark_pipeline(p$check_input, data)`.

## Next steps

[`vignette("testing-patterns")`](https://ian-flores.github.io/securebench/articles/testing-patterns.md)
covers building test sets, catching regressions in your tests, and more
on comparing versions.
