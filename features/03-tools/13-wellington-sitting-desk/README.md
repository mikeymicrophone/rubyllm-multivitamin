# Tools · 13 · Wellington sitting desk

The Beehive sitting desk has the sitting board, the division-bell card,
and the press-gallery latch. The first question is when clerk Aroha
clears the public gallery. The relief then asks about the bells. The
clerk stops the loop on a relief chit instead of asking the model to
speak again.

**What it teaches**

- Three tools are registered. `choice: :required` makes the model call
  one. The question decides which board.
- The time `10:12` and the ring `3 seconds` are only on those tools.
  The second request includes the first tool result, so the bell turn
  still has the gallery figure.
- `halt` and `RubyLLM::Tool::Halt` are not in RubyLLM 2.1.1. The desk
  calls `ask_later`, `generate`, and `run_tools`, then stops. The last
  message is the `:tool` chit. `complete?` is false because nobody asked
  the model to continue.

**Files**

| File | Role |
| --- | --- |
| [`sitting_desk.rb`](sitting_desk.rb) | Asks twice, then stops on the relief chit |
| [`sitting_desk_test.rb`](sitting_desk_test.rb) | Checks that halt is gone, and replays the cassette |
| [`cassettes/sitting_desk.yml`](cassettes/sitting_desk.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/13-wellington-sitting-desk/sitting_desk_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/13-wellington-sitting-desk/sitting_desk_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
