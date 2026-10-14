# Streaming · 04 · Neah Bay pilot ladder steps

The mate on the pilot boat off Neah Bay calls the boarding ladder in the
order the card lists it: side ropes, wooden steps, spreaders, then manropes.
A chunk can end in the middle of a sentence. The order is in the joined
speech, which is the message returned after the stream.

**What it teaches**

- Ordered steps survive a flush mid-sentence. Read them from the joined
  `content`, not from any one chunk.
- `ask` returns the assistant `Message`. That object is `chat.messages.last`.
- `role`, `finish_reason`, and `stopped?` are read from the returned message
  the same way they are read after an `ask` without a block.

**Files**

| File | Role |
| --- | --- |
| [`ladder_steps.rb`](ladder_steps.rb) | Streams the four checks |
| [`ladder_steps_test.rb`](ladder_steps_test.rb) | Replays the cassette and checks the order |
| [`cassettes/ladder_steps.yml`](cassettes/ladder_steps.yml) | The streamed inspection |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/04-neah-bay-ladder-steps/ladder_steps.rb
bundle exec ruby features/02-streaming/04-neah-bay-ladder-steps/ladder_steps_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`.
Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/02-streaming/04-neah-bay-ladder-steps/ladder_steps_test.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
