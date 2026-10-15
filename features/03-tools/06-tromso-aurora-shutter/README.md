# Tools · 06 · Tromsø aurora shutter window

The night photographer on Kvaløya first registers a Kp-index tool, then
clears the set with `with_tools(nil)` and registers the shutter window.
There is no `with_tool` singular. The Kp floor `05:48` never leaves the
cleared tool.

**What it teaches**

- `with_tools(nil)` clears the set. The next `with_tools` starts a new one.
- The cleared tool is absent from the request.
- RubyLLM 2.1.1 has no `with_tool`.

**Files**

| File | Role |
| --- | --- |
| [`shutter_window.rb`](shutter_window.rb) | Clears the Kp tool, then asks the shutter window |
| [`shutter_window_test.rb`](shutter_window_test.rb) | Checks the registered set and replays the cassette |
| [`cassettes/shutter_window.yml`](cassettes/shutter_window.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/06-tromso-aurora-shutter/shutter_window_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/06-tromso-aurora-shutter/shutter_window_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
