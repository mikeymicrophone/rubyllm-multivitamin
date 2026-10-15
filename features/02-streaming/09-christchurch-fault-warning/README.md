# Streaming · 09 · Christchurch Alpine Fault warning

The civic desk in Christchurch copies a shaking warning: intensity 8 and
35 schools closed on the Alpine Fault. The name of the fault is read after
the chunks are joined. The first chunks are reasoning, so the first spoken
token is not the first chunk.

**What it teaches**

- `Alpine Fault` is matched on the joined speech. A narrow no-break space
  can sit between the words, and `[[:space:]]` matches it.
- First-token latency is the monotonic clock from the start of `ask` until
  the first chunk whose `content` is non-empty.
- Chunks before that index have empty `content`. At least one of them carries
  `thinking.text`.
- A cassette replay yields those chunks from the recorded body, so the
  measured seconds are parse time. The test checks the order of the clock,
  not a live network delay.

**Files**

| File | Role |
| --- | --- |
| [`fault_warning.rb`](fault_warning.rb) | Streams the warning and times the first spoken chunk |
| [`fault_warning_test.rb`](fault_warning_test.rb) | Replays the cassette and checks the join and the clock |
| [`cassettes/fault_warning.yml`](cassettes/fault_warning.yml) | The streamed warning |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/09-christchurch-fault-warning/fault_warning.rb
bundle exec ruby features/02-streaming/09-christchurch-fault-warning/fault_warning_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`.
Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/02-streaming/09-christchurch-fault-warning/fault_warning_test.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
