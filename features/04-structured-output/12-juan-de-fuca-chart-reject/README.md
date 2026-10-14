# Structured output · 12 · Juan de Fuca chart reject

The chart desk tries to file notice 1842 for Ediz Hook with strict mode on and the bearing left optional. OpenAI rejects that request. A repaired schema keeps bearing required and allows null. The desk also refuses a notice that arrived with no station at all.

**What it teaches**

- `strict: true` plus a property missing from `required` is HTTP 400. `RubyLLM::BadRequestError` names `ChartCorrection` and `bearing`.
- `any_of` of `string` and `null`, still listed in `required`, stays `strict: true`. The parsed bearing is `null`.
- `accept_notice` raises `MissingStation` when `station` is blank. That check does not call a provider.
- `supports?(:structured_output)` and `supports?(:judgment)` disagree by model. `whisper-1` has neither. `gpt-4.1-mini` has structured output only. `gpt-6-luna` has both. The configured default judgment model is `jev-latest`, so a Luna decision has to name `gpt-6-luna` and `provider: :openai`.

**Files**

| File | Role |
| --- | --- |
| [`chart_reject.rb`](chart_reject.rb) | Records the 400, then the repaired notice |
| [`chart_reject_test.rb`](chart_reject_test.rb) | Replays the cassette and checks the registry |
| [`cassettes/chart_reject.yml`](cassettes/chart_reject.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

```sh
bundle exec ruby features/04-structured-output/12-juan-de-fuca-chart-reject/chart_reject_test.rb
```

Re-record:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/12-juan-de-fuca-chart-reject/chart_reject_test.rb
```

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The registry checks do not call the network.
