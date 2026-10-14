# Streaming · 03 · Anacortes retort climb

The retort man at the Anacortes cannery calls the come-up on retort No. 2:
180 F, 210 F, 240 F, then the hold at 242 F. The figures arrive in separate
chunks. The office log is the joined speech, which is the message `ask`
returns.

**What it teaches**

- A numeric series is split wherever the stream flushes. A chunk may hold
  `24` while the next holds `2`.
- Joining the non-empty pieces reproduces `message.content`.
- `ask` returns that message, and it is the assistant turn now stored on
  `chat.messages`.

**Files**

| File | Role |
| --- | --- |
| [`retort_climb.rb`](retort_climb.rb) | Streams the come-up and keeps the pieces |
| [`retort_climb_test.rb`](retort_climb_test.rb) | Replays the cassette and checks the order of the temperatures |
| [`cassettes/retort_climb.yml`](cassettes/retort_climb.yml) | The streamed come-up |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/03-anacortes-retort-climb/retort_climb.rb
bundle exec ruby features/02-streaming/03-anacortes-retort-climb/retort_climb_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`.
Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/02-streaming/03-anacortes-retort-climb/retort_climb_test.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
