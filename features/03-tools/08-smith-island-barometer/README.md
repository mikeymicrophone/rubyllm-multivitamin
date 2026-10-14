# Tools · 08 · Smith Island barometer

The weather watch asks for the mercury at Smith Island. The glass is off
the board, so `execute` raises. The exception reaches the caller. The
model never sees a tool result.

**What it teaches**

- A raise inside `execute` propagates out of `ask`. Rescue it outside
  the call.
- RubyLLM does not wrap that exception as `{ error: }` and does not
  append a `:tool` message.
- The assistant message that requested the tool is already on
  `chat.messages`, so the roles are system, user, assistant.
- The cassette holds the one completion that asked for the tool. There
  is no follow-up request.

**Files**

| File | Role |
| --- | --- |
| [`barometer_glass.rb`](barometer_glass.rb) | Raises when the glass is unseated |
| [`barometer_glass_test.rb`](barometer_glass_test.rb) | Checks the raise locally and replays the cassette |
| [`cassettes/barometer_glass.yml`](cassettes/barometer_glass.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/08-smith-island-barometer/barometer_glass_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/08-smith-island-barometer/barometer_glass_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
