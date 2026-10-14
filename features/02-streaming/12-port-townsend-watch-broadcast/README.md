# Streaming · 12 · Port Townsend watch broadcast

The Point Wilson watch speaks a gale for Admiralty Inlet. Two stations are
listening: the Port Townsend slip, and the foghorn tender Alden alongside
that slip. Each spoken chunk is broadcast to both. This folder stays on
plain Ruby. The channel is the shape a later Rails integration can wrap.

**What it teaches**

- A subscriber list receives every non-empty `chunk.content`.
- Empty chunks are not broadcast, so each station's tape equals the joined
  speech and the message `ask` returns.
- `subscribe` and `broadcast` are the calls an Action Cable channel would
  make. No Rails code runs here.

**Files**

| File | Role |
| --- | --- |
| [`watch_broadcast.rb`](watch_broadcast.rb) | Streams the gale and broadcasts each spoken chunk |
| [`watch_broadcast_test.rb`](watch_broadcast_test.rb) | Replays the cassette and checks both tapes |
| [`cassettes/watch_broadcast.yml`](cassettes/watch_broadcast.yml) | The streamed broadcast |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/12-port-townsend-watch-broadcast/watch_broadcast.rb
bundle exec ruby features/02-streaming/12-port-townsend-watch-broadcast/watch_broadcast_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`.
Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/02-streaming/12-port-townsend-watch-broadcast/watch_broadcast_test.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
