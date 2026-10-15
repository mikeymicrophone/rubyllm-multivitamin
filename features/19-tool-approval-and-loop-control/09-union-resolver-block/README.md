# Tool approval and loop control · 09 · Union resolver block

The Hood Canal Bridge tender at Union does not throw the lifting span
from `approve`. A ledger hash is the decision. The resolver returns
`nil` until the tug Salish Star is written in, then `true`.

**What it teaches**

- `requires_approval { |tool_call| ... }` is consulted by the loop, not
  at class definition. Return `nil` to keep waiting, `true` to execute.
- When a resolver is declared it is the source of truth. `approve` does
  not override it.
- The loop may consult the block more than once while the call is
  pending. The Union ledger is an idempotent read.

**Files**

| File | Role |
| --- | --- |
| [`bridge_opening.rb`](bridge_opening.rb) | Parks the lift, then grants it from the ledger |
| [`bridge_opening_test.rb`](bridge_opening_test.rb) | Replays the cassette |
| [`cassettes/bridge_opening.yml`](cassettes/bridge_opening.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/19-tool-approval-and-loop-control/09-union-resolver-block/bridge_opening_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/19-tool-approval-and-loop-control/09-union-resolver-block/bridge_opening_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
