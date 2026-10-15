# Tokens and cost · 12 · Turn Point current-halt cancelled usage

The current clerk at Turn Point Light starts calling the Boundary Pass
race and is stopped after two spoken pieces, before slack fills for the
tanker Polar Adventure. The assistant turn never lands. The cancelled
attempt still sits on the chat's usage ledger.

**What it teaches**

- `chat.cancel` raises `RubyLLM::CancelledError` after the block. The
  assistant turn is not appended, so `chat.messages` stays system and
  user.
- That attempt is still on `chat.usage_entries`, with status
  `:cancelled`.
- Usage arrives on the last streamed chunk. Stopping before that chunk
  leaves no defensible counts, so `chat.cost.total` is `nil` rather than
  a fake zero. Summing tokens off `chat.messages` undercounts the work.

**Files**

| File | Role |
| --- | --- |
| [`current_halt.rb`](current_halt.rb) | Starts the race call and cancels after two pieces |
| [`current_halt_test.rb`](current_halt_test.rb) | Replays the cassette and checks the cancelled ledger |
| [`cassettes/current_halt.yml`](cassettes/current_halt.yml) | The streamed Chat Completions body, including later deltas |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/12-turn-point-current-halt/current_halt.rb
bundle exec ruby features/12-tokens-and-cost/12-turn-point-current-halt/current_halt_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/12-turn-point-current-halt/current_halt.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter, with thinking off
so the first two spoken pieces arrive before the halt. Fallback if that
slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 15 October 2026.
