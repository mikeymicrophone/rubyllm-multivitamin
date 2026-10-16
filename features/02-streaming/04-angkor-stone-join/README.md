# Streaming · 04 · Angkor stone-join steps

The conservator on the west gallery at Angkor Wat calls the stone-join
inspection in the order the card lists it: laterite core, sandstone facing,
iron cramps, then lime mortar. A chunk can end in the middle of a sentence.
The order is in the joined speech, which is the message returned after the
stream.

**What it teaches**

- `before_message` and `after_message` bracket the stream (the 2.1.1 replacements for `on_new_message` and `on_end_message`). Bound methods record lifecycle events; a named lambda collects chunks into an instance-owned tape.
- Ordered steps survive a flush mid-sentence. Read them from the joined
  `content`, not from any one chunk.
- `ask` returns the assistant `Message`. That object is `chat.messages.last`.
- `role`, `finish_reason`, and `stopped?` are read from the returned message
  the same way they are read after an `ask` without a block.

**Files**

| File | Role |
| --- | --- |
| [`stone_join.rb`](stone_join.rb) | Streams the four checks |
| [`stone_join_test.rb`](stone_join_test.rb) | Replays the cassette and checks the order |
| [`cassettes/stone_join.yml`](cassettes/stone_join.yml) | The streamed inspection |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/04-angkor-stone-join/stone_join.rb
bundle exec ruby features/02-streaming/04-angkor-stone-join/stone_join_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of OpenAI `gpt-4.1-mini`.
Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/02-streaming/04-angkor-stone-join/stone_join_test.rb
```

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter
`:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback:
`gpt-4o-mini`. Re-record on the free slug with `LIVE_PROVIDER=openrouter`.
