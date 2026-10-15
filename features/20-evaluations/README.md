# Evaluations

`RubyLLM::Evaluation` subclasses implement `perform(input)`. A YAML (or Ruby) dataset beside the class lists `name`, `inputs`, and `expected_output`. `SupportEvaluation.run` returns a report with `passed?`. The default evaluator asks the chat model whether the answer matches the expected meaning. Custom evaluators, Judges, RSpec/Minitest helpers, and Rake (`ruby_llm:eval`) sit on top. Each trial is an OpenTelemetry workflow when tracing is on.

Official reference: [Evaluations](https://rubyllm.com/evaluations/).

## RubyLLM 2.1.1 entry points

- `class SupportEvaluation < RubyLLM::Evaluation`
- `def perform(input)`
- `app/evals/support_evaluation.yml` cases
- `SupportEvaluation.run` and `report.passed?`
- `bin/rails "ruby_llm:eval[SupportEvaluation]"`
- custom evaluators, Judges, RSpec/Minitest

## Providers that can record it

The agent under test records on whatever chat provider it uses. The grader is a second chat (default `default_model`). This catalog's cheap path is OpenAI `gpt-4.1-mini` for both, or OpenRouter `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap allows. `RubyLLM::Judge` graders that need Decisions use OpenAI `gpt-6-luna`.

## Examples (0 of 13 bottled)

01. Keyport return-window cases — planned
02. Poulsbo structured inputs — planned
03. Liberty Bay multi-turn eval — planned
04. Agate Pass tool-call eval — planned
05. Bainbridge custom evaluator — planned
06. Eagle Harbor Judge grader — planned
07. Blakely Rock Minitest helper — planned
08. Restoration eval Rake task — planned
09. Alki JSON report tokens — planned
10. Duwamish expected vs output — planned
11. Elliott Bay progress callback — planned
12. Shilshole failing case reason — planned
13. Golden Gardens desk eval capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
