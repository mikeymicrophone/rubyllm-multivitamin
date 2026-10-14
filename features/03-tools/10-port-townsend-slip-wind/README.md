# Tools · 10 · Port Townsend slip wind

The slip watch at Port Townsend reads the north mast and the south mast
on one turn. Each reading comes back as a hash of knots and gust. On the
transcript that hash is JSON.

**What it teaches**

- `with_tool_options(calls: :many)` sends `"parallel_tool_calls":true`.
  `choice: :auto` lets the first assistant message hold both mast calls,
  followed by two `:tool` messages.
- `execute` returns a Hash. `Tool.split_result` calls `to_json`, so
  `message.content` is a String of JSON. A String return is left as that
  string. The Point Wilson tide board is the string shape.
- The gusts 27 and 31 are not in the question.

**Files**

| File | Role |
| --- | --- |
| [`slip_wind.rb`](slip_wind.rb) | Asks for both masts in one turn |
| [`slip_wind_test.rb`](slip_wind_test.rb) | Checks JSON versus a string locally and replays the cassette |
| [`cassettes/slip_wind.yml`](cassettes/slip_wind.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/10-port-townsend-slip-wind/slip_wind_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/10-port-townsend-slip-wind/slip_wind_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
