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
| [`buoy_battery_test.rb`](buoy_battery_test.rb) | Checks both return shapes locally and the cassette when it exists |
| [`cassettes/buoy_battery.yml`](cassettes/buoy_battery.yml) | Not recorded yet |

**Try it**

The cassette is not recorded. The chat test skips with `cassette pending
live recording`.

```sh
bundle exec ruby features/03-tools/07-ediz-hook-buoy-battery/buoy_battery_test.rb
```

Record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/03-tools/07-ediz-hook-buoy-battery/buoy_battery_test.rb
```

Do not hand-author the cassette.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
