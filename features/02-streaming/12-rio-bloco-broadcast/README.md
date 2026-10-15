# Streaming · 12 · Rio Carnival bloco broadcast

The carnival desk at the Cidade do Samba speaks a rain hold for the
Sambadrome. Two escolas are listening: Mangueira, and Portela with the
porta-bandeira Lívia alongside that float. Each spoken chunk is broadcast
to both. This folder stays on plain Ruby. The channel is the shape a later
Rails integration can wrap.

**What it teaches**

- A subscriber list receives every non-empty `chunk.content`.
- Empty chunks are not broadcast, so each school's tape equals the joined
  speech and the message `ask` returns.
- `subscribe` and `broadcast` are the calls an Action Cable channel would
  make. No Rails code runs here.

**Files**

| File | Role |
| --- | --- |
| [`bloco_broadcast.rb`](bloco_broadcast.rb) | Streams the hold and broadcasts each spoken chunk |
| [`bloco_broadcast_test.rb`](bloco_broadcast_test.rb) | Replays the cassette and checks both tapes |
| [`cassettes/bloco_broadcast.yml`](cassettes/bloco_broadcast.yml) | The streamed broadcast |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/12-rio-bloco-broadcast/bloco_broadcast.rb
bundle exec ruby features/02-streaming/12-rio-bloco-broadcast/bloco_broadcast_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of OpenAI `gpt-4.1-mini`.
Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/02-streaming/12-rio-bloco-broadcast/bloco_broadcast_test.rb
```

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter
`:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback:
`gpt-4o-mini`. Re-record on the free slug with `LIVE_PROVIDER=openrouter`.
