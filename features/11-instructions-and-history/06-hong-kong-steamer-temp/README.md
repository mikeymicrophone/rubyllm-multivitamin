# Instructions and history · 06 · Hong Kong steamer temperature cleared

The kitchen clerk at the Chan family dim-sum kitchen in Sham Shui Po
holds the 07:10 siu-mai under a tight temperature, then clears sampling
before asking whether the 07:50 har-gow can go.

**What it teaches**

- `with_temperature(0.1)` sends `"temperature":0.1` on the first request.
- `with_temperature(nil)` clears the override. `chat.temperature` is then
  `nil`.
- The request after the clear omits the field, and the model uses its
  own default.

**Files**

| File | Role |
| --- | --- |
| [`steamer_clear.rb`](steamer_clear.rb) | Holds the siu-mai, clears sampling, asks the har-gow |
| [`steamer_clear_test.rb`](steamer_clear_test.rb) | Replays the cassette and checks both request bodies |
| [`cassettes/steamer_clear.yml`](cassettes/steamer_clear.yml) | Live recording of both asks |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/06-hong-kong-steamer-temp/steamer_clear.rb
bundle exec ruby features/11-instructions-and-history/06-hong-kong-steamer-temp/steamer_clear_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/06-hong-kong-steamer-temp/steamer_clear.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` inverted a Yes/No standing
order on 16 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
