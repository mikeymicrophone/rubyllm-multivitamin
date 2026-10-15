# Structured output · 12 · Alexandria papyrus reject

The catalogue desk tries to file notice 1842 for the Zenon papyrus with strict mode on and the findspot left optional. OpenAI rejects that request. A repaired schema keeps findspot required and allows null. The desk also refuses a notice that arrived with no shelfmark at all.

**What it teaches**

- `strict: true` plus a property missing from `required` is HTTP 400. `RubyLLM::BadRequestError` names `PapyrusCorrection` and `findspot`.
- `any_of` of `string` and `null`, still listed in `required`, stays `strict: true`. The parsed findspot is `null`.
- `accept_notice` raises `MissingShelfmark` when `shelfmark` is blank. That check does not call a provider.
- `supports?(:structured_output)` and `supports?(:judgment)` disagree by model. `whisper-1` has neither. `gpt-4.1-mini` has structured output only. `gpt-6-luna` has both. The configured default judgment model is `jev-latest`, so a Luna decision has to name `gpt-6-luna` and `provider: :openai`.

**Files**

| File | Role |
| --- | --- |
| [`papyrus_reject.rb`](papyrus_reject.rb) | Records the 400, then the repaired notice |
| [`papyrus_reject_test.rb`](papyrus_reject_test.rb) | Replays the cassette and checks the registry |
| [`cassettes/papyrus_reject.yml`](cassettes/papyrus_reject.yml) | Live recording of `gpt-4.1-mini` |

**Try it**

```sh
bundle exec ruby features/04-structured-output/12-alexandria-papyrus-reject/papyrus_reject_test.rb
```

Re-record:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/12-alexandria-papyrus-reject/papyrus_reject_test.rb
```

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The registry checks do not call the network.
