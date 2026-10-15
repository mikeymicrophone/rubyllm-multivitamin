# Streaming · 03 · Kathmandu brick kiln climb

The fireman at the Bhaktapur brick field outside Kathmandu calls the
come-up on kiln No. 2: 180 C, 210 C, 240 C, then the hold at 242 C. The
figures arrive in separate chunks. The office log is the joined speech,
which is the message `ask` returns.

**What it teaches**

- A numeric series is split wherever the stream flushes. A chunk may hold
  `24` while the next holds `2`.
- Joining the non-empty pieces reproduces `message.content`.
- `ask` returns that message, and it is the assistant turn now stored on
  `chat.messages`.

**Files**

| File | Role |
| --- | --- |
| [`kiln_climb.rb`](kiln_climb.rb) | Streams the come-up and keeps the pieces |
| [`kiln_climb_test.rb`](kiln_climb_test.rb) | Replays the cassette and checks the order of the temperatures |
| [`cassettes/kiln_climb.yml`](cassettes/kiln_climb.yml) | The streamed come-up |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/03-kathmandu-kiln-climb/kiln_climb.rb
bundle exec ruby features/02-streaming/03-kathmandu-kiln-climb/kiln_climb_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`.
Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/02-streaming/03-kathmandu-kiln-climb/kiln_climb_test.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
