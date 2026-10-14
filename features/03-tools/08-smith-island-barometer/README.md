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
| [`barometer_glass_test.rb`](barometer_glass_test.rb) | Checks the raise locally and the cassette when it exists |
| [`cassettes/barometer_glass.yml`](cassettes/barometer_glass.yml) | Not recorded yet |

**Try it**

The cassette is not recorded. The chat test skips with `cassette pending
live recording`.

```sh
bundle exec ruby features/03-tools/08-smith-island-barometer/barometer_glass_test.rb
```

Record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/03-tools/08-smith-island-barometer/barometer_glass_test.rb
```

Do not hand-author the cassette.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
