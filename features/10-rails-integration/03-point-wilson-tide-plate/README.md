# Rails integration · 03 · Point Wilson tide plate

The incoming watch reads the chalked board from a photograph handed
to a persisted tide-plate log. `ask` takes `with:` the PNG.

**What it teaches**

- `ask` on a persisted chat accepts `with:` a local photograph.
- The user row is saved. The request carries `data:image/png;base64`.
- Without Active Storage the blob is not an association. The file still goes out on that first ask.

**Files**

| File | Role |
| --- | --- |
| [`tide_plate.rb`](tide_plate.rb) | Creates the tide-plate log and asks with the photograph |
| [`tide_plate_test.rb`](tide_plate_test.rb) | Replays the cassette and checks the heights and the image part |
| [`tide-board.png`](tide-board.png) | The posted Point Wilson board |
| [`cassettes/tide_plate.yml`](cassettes/tide_plate.yml) | The Chat Completions round-trip with the image |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/03-point-wilson-tide-plate/tide_plate.rb
bundle exec ruby features/10-rails-integration/03-point-wilson-tide-plate/tide_plate_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after the
free OpenRouter slugs hit the daily cap on 14 October 2026. Re-record
it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/03-point-wilson-tide-plate/tide_plate.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Checked 14 October 2026.
