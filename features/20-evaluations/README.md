# Evaluations

`RubyLLM::Evaluation` subclasses implement `perform(input)`. A YAML (or Ruby)
dataset beside the class lists `name`, `inputs`, and `expected_output`.
`SupportEvaluation.run` returns a report with `passed?`. The default evaluator
asks the chat model whether the answer matches the expected meaning. Custom
evaluators, Judges, RSpec/Minitest helpers, and Rake (`ruby_llm:eval`) sit on
top. Each trial is an OpenTelemetry workflow when tracing is on.

Official reference: [Evaluations](https://rubyllm.com/evaluations/).

## RubyLLM 2.1.1 entry points

- `class SupportEvaluation < RubyLLM::Evaluation`
- `def perform(input)`
- `app/evals/support_evaluation.yml` cases
- `SupportEvaluation.run` and `report.passed?`
- `bin/rails "ruby_llm:eval[SupportEvaluation]"`
- custom evaluators, Judges, RSpec/Minitest

## Providers that can record it

The agent under test records on whatever chat provider it uses. The grader is a
second chat (default `default_model`) and needs structured output. This
catalog's cheap path is OpenAI `gpt-4.1-mini` for both. `RubyLLM::Judge`
graders that need Decisions use OpenAI `gpt-6-luna`. Free OpenRouter slugs do
not speak the grader schema reliably.

## Examples (13 of 13 bottled)

01. [Marrakech argan return window](01-marrakech-argan-window/) — available
02. [Chiang Rai miang-leaf structured inputs](02-chiang-rai-miang-leaf/) — available
03. [Lhasa tsampa-mill multi-turn](03-lhasa-tsampa-mill/) — available
04. [Toledo damascene-wire tool](04-toledo-damascene-wire/) — available
05. [Brno puppet-string custom evaluator](05-brno-puppet-string/) — available
06. [Tabriz carpet-knot Judge grader](06-tabriz-carpet-knot/) — available
07. [Guayaquil toquilla-brim Minitest helper](07-guayaquil-toquilla-brim/) — available
08. [Mopti banco-brick Rake task](08-mopti-banco-brick/) — available
09. [Yazd windcatcher JSON report tokens](09-yazd-windcatcher-draft/) — available
10. [Seville faralae-ruffle expected versus output](10-seville-faralae-ruffle/) — available
11. [Lomé wax-print progress callback](11-lome-wax-print-block/) — available
12. [Bujumbura drum-skin failing case](12-bujumbura-drum-skin/) — available
13. [Samarkand paper-vat desk capstone](13-samarkand-paper-vat/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | YAML cases, `perform(input)`, default `:correctness` |
| 02 | Dataset `inputs` as a Hash |
| 03 | `perform` returns the `Chat` so the grader sees both turns |
| 04 | A forced tool round sits on the trial |
| 05 | `evaluation :names_the_bar` beside `:correctness` |
| 06 | `RubyLLM::Judge` with `evaluation :agrees, minimum: 0.5` |
| 07 | `extend RubyLLM::Evaluation::Minitest` then `evaluates` |
| 08 | `app/evals/*_evaluation.rb` and `report.save` |
| 09 | Saved JSON report carries `tokens` and `id` |
| 10 | `evaluator false` compares `output` to `expected_output` |
| 11 | `run` yields each `Trial` in dataset order |
| 12 | A wrong count fails `:correctness`; `passed?` is false |
| 13 | Capstone: Hash inputs, two criteria, progress, saved tokens |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
