# Text to speech · 09 · Fort Flagler tokens and cost

The park clerk at Fort Flagler wants the radio card spoken, then records
usage on the work order the way a chat turn would. Park page:
<https://www.parks.wa.gov/508/Fort-Flagler>.

**What it teaches**

- `Speech#tokens.input` and `tokens.output` are `nil` on `tts-1`.
- `Speech#cost.total` is `nil`. The response is raw audio, not JSON usage.
- That is not the same as a free chat model's `cost` of `0`. The bundled
  registry has no speech price for `tts-1`.

**Files**

| File | Role |
| --- | --- |
| [`flagler_cost.rb`](flagler_cost.rb) | Speaks the card and reads usage |
| [`flagler_cost_test.rb`](flagler_cost_test.rb) | Replays the cassette |
| [`cassettes/flagler_cost.yml`](cassettes/flagler_cost.yml) | Live OpenAI recording of `tts-1` |

**Try it**

```sh
bundle exec ruby features/17-text-to-speech/09-fort-flagler-tokens-cost/flagler_cost_test.rb
```

Re-record with `LIVE=1 LIVE_PROVIDER=openai`. Do not hand-author the cassette.

**Model**

Recorded on `tts-1` with `provider: :openai`.
