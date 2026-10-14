# Streaming · 05 · Fresnel gallery rotation

The lens keeper in the Point Wilson gallery times the fourth-order Fresnel:
flash 0.4 seconds, eclipse 9.6 seconds. The gallery phone speaks only the
chunks that carry words. A second timing is capped at 64 output tokens, and
that cap is spent on reasoning.

**What it teaches**

- Chunks with an empty `content` are not appended to the spoken timing.
  Reasoning-only chunks carry the delta on `thinking.text` instead.
- Joining the spoken pieces reproduces the returned message.
- `with_max_output_tokens(64)` is `"max_tokens":64` on the wire. The stream
  can finish with `finish_reason` `:max_tokens`, `content` nil, and the
  draft on `thinking.text`. `ask` returns that message. It does not raise.

**Files**

| File | Role |
| --- | --- |
| [`gallery_rotation.rb`](gallery_rotation.rb) | Streams the open timing, then the capped timing |
| [`gallery_rotation_test.rb`](gallery_rotation_test.rb) | Replays both and checks the empty note |
| [`cassettes/gallery_rotation.yml`](cassettes/gallery_rotation.yml) | The two streamed timings |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/05-fresnel-gallery-rotation/gallery_rotation.rb
bundle exec ruby features/02-streaming/05-fresnel-gallery-rotation/gallery_rotation_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`.
Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/02-streaming/05-fresnel-gallery-rotation/gallery_rotation_test.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
