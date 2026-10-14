# Tools · 13 · Admiralty Inlet watch desk

The Point Wilson watch has the tide board, the horn card, and the lens
cabinet latch. The first question is when Alden clears the kelp ledge.
The relief then asks about the horn. The clerk stops the loop on a
relief chit instead of asking the model to speak again.

**What it teaches**

- Three tools are registered. `choice: :required` makes the model call
  one. The question decides which board.
- The time `10:12` and the blast `3 seconds` are only on those tools.
  The second request includes the first tool result, so the horn turn
  still has the tide figure.
- `halt` and `RubyLLM::Tool::Halt` are not in RubyLLM 2.1.1. The desk
  calls `ask_later`, `generate`, and `run_tools`, then stops. The last
  message is the `:tool` chit. `complete?` is false because nobody asked
  the model to continue.

**Files**

| File | Role |
| --- | --- |
| [`watch_desk.rb`](watch_desk.rb) | Asks twice, then stops on the relief chit |
| [`watch_desk_test.rb`](watch_desk_test.rb) | Checks that halt is gone, and the cassette when it exists |
| [`cassettes/watch_desk.yml`](cassettes/watch_desk.yml) | Not recorded yet |

**Try it**

The cassette is not recorded. The chat test skips with `cassette pending
live recording`. The halt check does not call the provider.

```sh
bundle exec ruby features/03-tools/13-admiralty-inlet-watch-desk/watch_desk_test.rb
```

Record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/03-tools/13-admiralty-inlet-watch-desk/watch_desk_test.rb
```

Do not hand-author the cassette.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
