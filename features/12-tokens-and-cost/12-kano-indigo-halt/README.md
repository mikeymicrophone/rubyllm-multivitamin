# Tokens and cost · 12 · Kano indigo-halt cancelled usage

The dye clerk at the Kano indigo pits starts calling the four vat
figures and is stopped after two spoken pieces, before rinse fills for
the buyer Halima. The assistant turn never lands. The cancelled attempt
still sits on the chat's usage ledger.

**What it teaches**

- `chat.cancel` raises `RubyLLM::CancelledError` after the block. The
  assistant turn is not appended, so `chat.messages` stays system and
  user.
- That attempt is still on `chat.usage_entries`, with status
  `:cancelled`.
- Usage arrives on the last streamed chunk. Stopping before that chunk
  leaves `tokens.input` nil. The Chat Completions parser still defaults
  omitted `cache_write` to `0`, and this `:free` slug is priced at `$0`
  per million, so `chat.cost.total` is `0.0` rather than nil. Summing
  tokens off `chat.messages` undercounts: there is no assistant turn, and
  the cassette still holds the later usage chunk the halt never applied.

**Files**

| File | Role |
| --- | --- |
| [`indigo_halt.rb`](indigo_halt.rb) | Starts the pit call and cancels after two pieces |
| [`indigo_halt_test.rb`](indigo_halt_test.rb) | Replays the cassette and checks the cancelled ledger |
| [`cassettes/indigo_halt.yml`](cassettes/indigo_halt.yml) | The streamed Chat Completions body, including later deltas |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/12-kano-indigo-halt/indigo_halt.rb
bundle exec ruby features/12-tokens-and-cost/12-kano-indigo-halt/indigo_halt_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/12-kano-indigo-halt/indigo_halt.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter, with thinking off
so the first two spoken pieces arrive before the halt. Fallback if that
slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 16 October 2026.
