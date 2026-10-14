# Tools · 07 · Ediz Hook buoy battery

The buoy tender at Ediz Hook asks for LL-17. That buoy is not on the
ledger. The tool returns an error hash naming LL-4. The tender calls
the tool again, and the voltage on that card is what the answer reports.

**What it teaches**

- A recoverable miss is `{ error: "..." }`, not an exception.
- `Tool.split_result` turns that hash into a JSON string. The `:tool`
  message content is the JSON. The next request carries it.
- A later call that finds the card returns a String, so that tool
  message is the sentence itself.
- `choice: :required` is on the first request. RubyLLM clears a forced
  choice after the tool runs, so the retry request has no `tool_choice`.

**Files**

| File | Role |
| --- | --- |
| [`buoy_battery.rb`](buoy_battery.rb) | Returns an error for LL-17 and the card for LL-4 |
| [`buoy_battery_test.rb`](buoy_battery_test.rb) | Checks both return shapes locally and replays the cassette |
| [`cassettes/buoy_battery.yml`](cassettes/buoy_battery.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/07-ediz-hook-buoy-battery/buoy_battery_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/07-ediz-hook-buoy-battery/buoy_battery_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
