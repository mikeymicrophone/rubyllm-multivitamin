# Tools · 10 · Port Townsend slip wind

The slip watch at Port Townsend reads the north mast and the south mast
on one turn. Each reading comes back as a hash of knots and gust. On the
transcript that hash is JSON.

**What it teaches**

- `with_tool_options(calls: :many)` sends `"parallel_tool_calls":true`.
  One assistant message can hold two tool calls, followed by two `:tool`
  messages.
- `execute` returns a Hash. `Tool.split_result` calls `to_json`, so
  `message.content` is a String of JSON. A String return is left as that
  string. The Point Wilson tide board is the string shape.
- The gusts 27 and 31 are not in the question.

**Files**

| File | Role |
| --- | --- |
| [`slip_wind.rb`](slip_wind.rb) | Asks for both masts in one turn |
| [`slip_wind_test.rb`](slip_wind_test.rb) | Checks JSON versus a string locally and the cassette when it exists |
| [`cassettes/slip_wind.yml`](cassettes/slip_wind.yml) | Not recorded yet |

**Try it**

The cassette is not recorded. The chat test skips with `cassette pending
live recording`.

```sh
bundle exec ruby features/03-tools/10-port-townsend-slip-wind/slip_wind_test.rb
```

Record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/03-tools/10-port-townsend-slip-wind/slip_wind_test.rb
```

Do not hand-author the cassette.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
