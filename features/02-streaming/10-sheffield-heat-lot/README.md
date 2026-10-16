# Streaming · 10 · Sheffield cutlery heat-lot

The stamp clerk at the Kelham Island cutlery works in Sheffield streams the
morning heat's lot code, `SHF-2026-1014-R2-B3`, for rack 3 on furnace No. 2.
The stream can flush in the middle of that code. The label is the joined
chunks.

**What it teaches**

- A stored lambda receives chunks through `ask(..., &collector)`.
- A lot code is read from the joined `content`, which equals the message
  `ask` returns. This recording splits `SHF-2026-1014-R2-B3` so no piece
  holds the whole code.
- `Rack 3` in this cassette uses a normal space. The assertion still
  uses `[[:space:]]`, because the same model puts U+202F beside a number
  on other boards. That character is in the Muscat date-pack dictation.

**Files**

| File | Role |
| --- | --- |
| [`heat_lot.rb`](heat_lot.rb) | Streams the label and keeps the pieces |
| [`heat_lot_test.rb`](heat_lot_test.rb) | Replays the cassette and reads the code from the join |
| [`cassettes/heat_lot.yml`](cassettes/heat_lot.yml) | The streamed label |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/10-sheffield-heat-lot/heat_lot.rb
bundle exec ruby features/02-streaming/10-sheffield-heat-lot/heat_lot_test.rb
```

Both commands replay the cassette. No API key is required. The script also
prints each piece so the flush in the middle of the code is visible.

The cassette is a live recording of OpenAI `gpt-4.1-mini`.
Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/02-streaming/10-sheffield-heat-lot/heat_lot_test.rb
```

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter
`:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback:
`gpt-4o-mini`. Re-record on the free slug with `LIVE_PROVIDER=openrouter`.
