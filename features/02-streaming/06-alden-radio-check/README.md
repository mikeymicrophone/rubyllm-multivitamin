# Streaming · 06 · Alden radio check

The foghorn tender Alden calls Point Wilson on channel 66. The watch
streams the check into the log, then reads the token counts. Those counts
are on the last chunk, not on the chunk that first reports `finish_reason`.

**What it teaches**

- A block on `ask` sends `stream_options: { include_usage: true }`.
- Every chunk before the last one has nil `tokens.input`, including a chunk
  that already carries `finish_reason`.
- The last chunk repeats `finish_reason` and carries `tokens.input`,
  `tokens.output`, and `tokens.thinking`. The returned message matches it.
- `cost.total` is the provider's reported cost. On this free slug it is 0.

**Files**

| File | Role |
| --- | --- |
| [`radio_check.rb`](radio_check.rb) | Streams the check and notes each chunk's tokens |
| [`radio_check_test.rb`](radio_check_test.rb) | Replays the cassette and checks the usage chunk |
| [`cassettes/radio_check.yml`](cassettes/radio_check.yml) | The streamed radio check |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/06-alden-radio-check/radio_check.rb
bundle exec ruby features/02-streaming/06-alden-radio-check/radio_check_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`.
Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/02-streaming/06-alden-radio-check/radio_check_test.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
