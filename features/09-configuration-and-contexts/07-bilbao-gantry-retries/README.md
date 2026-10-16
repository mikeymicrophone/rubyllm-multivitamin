# Configuration and contexts · 07 · Bilbao gantry retry knobs

The fitter Aitor on the Zorrotzaurre gantry in Bilbao turns Faraday
retries off on the torque context so a bolt check is one POST. The
catalog's global `max_retries` stays at 3.

**What it teaches**

- `max_retries`, `retry_interval`, and `retry_backoff_factor` are copied
  onto a context and do not leak back to `RubyLLM.config`.
- `max_retries` 0 on the cassette context keeps the recording to one
  interaction.
- The global retry count is still the library default after the torque
  chat.

**Files**

| File | Role |
| --- | --- |
| [`gantry_retries.rb`](gantry_retries.rb) | Sets retry knobs on the torque context and asks the bolt question |
| [`gantry_retries_test.rb`](gantry_retries_test.rb) | Replays the cassette and checks the knobs |
| [`cassettes/gantry_retries.yml`](cassettes/gantry_retries.yml) | One Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/07-bilbao-gantry-retries/gantry_retries.rb
bundle exec ruby features/09-configuration-and-contexts/07-bilbao-gantry-retries/gantry_retries_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/07-bilbao-gantry-retries/gantry_retries.rb
```

**Model**

Recorded 16 October 2026 on `nvidia/nemotron-3-super-120b-a12b:free`
with `provider: :openrouter`. `CONFIGURATION_OPENROUTER_PAID=1` records
`openai/gpt-4.1-mini` on OpenRouter. A 512-token output cap is set so a
paid request fits this workspace's credits. Fallback:
`LIVE_PROVIDER=openai` records native `gpt-4.1-mini`.
