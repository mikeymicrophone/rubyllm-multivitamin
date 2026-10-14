# Tools · 06 · Neah Bay pilot window

The mate off Neah Bay starts with a tide tool, clears it, and registers
the pilot ladder window. The ladder times are not in the question.

**What it teaches**

- `with_tools(nil)` clears every registered tool. A later `with_tools`
  starts a new set. RubyLLM 2.1.1 has no `with_tool`.
- The cleared tool's name is absent from the request body.
- The open times `09:10` and `11:40` come back on the tool message and
  in the answer.

**Files**

| File | Role |
| --- | --- |
| [`pilot_window.rb`](pilot_window.rb) | Clears the tide tool, then asks for the ladder window |
| [`pilot_window_test.rb`](pilot_window_test.rb) | Checks the cleared set locally and replays the cassette |
| [`cassettes/pilot_window.yml`](cassettes/pilot_window.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/06-neah-bay-pilot-window/pilot_window_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/06-neah-bay-pilot-window/pilot_window_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
