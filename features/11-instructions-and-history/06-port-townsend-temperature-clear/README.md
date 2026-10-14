# Instructions and history · 06 · Port Townsend temperature cleared

The slip clerk at the Port Townsend ferry terminal holds the 07:10
Salish under a tight temperature, then clears sampling before asking
whether the 07:50 Chetzemoka can go.

**What it teaches**

- `with_temperature(0.1)` sends `"temperature":0.1` on the first request.
- `with_temperature(nil)` clears the override. `chat.temperature` is then
  `nil`.
- The request after the clear omits the field, and the model uses its
  own default.

**Files**

| File | Role |
| --- | --- |
| [`temperature_clear.rb`](temperature_clear.rb) | Holds the Salish, clears sampling, asks the Chetzemoka |
| [`temperature_clear_test.rb`](temperature_clear_test.rb) | Replays the cassette and checks both request bodies |
| [`cassettes/temperature_clear.yml`](cassettes/temperature_clear.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/06-port-townsend-temperature-clear/temperature_clear.rb
bundle exec ruby features/11-instructions-and-history/06-port-townsend-temperature-clear/temperature_clear_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/06-port-townsend-temperature-clear/temperature_clear.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded:
free-models-per-day` on 14 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
