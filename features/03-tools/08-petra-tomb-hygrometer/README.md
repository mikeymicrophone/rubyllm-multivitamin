# Tools · 08 · Petra tomb hygrometer

The conservation watch at Petra asks for the Treasury hygrometer. The
glass is off the board. `execute` raises `TombGlassUnseated`. `ask`
leaves with that exception. No `:tool` message is appended.

**What it teaches**

- An exception raised inside `execute` leaves `ask`. It is not turned
  into a tool message and it is not sent back to the model.
- The assistant turn that requested the tool is already on the chat.
- The cassette has one HTTP interaction.

**Files**

| File | Role |
| --- | --- |
| [`tomb_glass.rb`](tomb_glass.rb) | Raises from `execute` and rescues outside `ask` |
| [`tomb_glass_test.rb`](tomb_glass_test.rb) | Checks the missing `:tool` role and replays the cassette |
| [`cassettes/tomb_glass.yml`](cassettes/tomb_glass.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/08-petra-tomb-hygrometer/tomb_glass_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/08-petra-tomb-hygrometer/tomb_glass_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
