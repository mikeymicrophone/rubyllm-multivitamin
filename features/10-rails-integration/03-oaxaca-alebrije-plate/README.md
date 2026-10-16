# Rails integration · 03 · Oaxaca alebrije-firing plate

The incoming kiln watch in San Martín Tilcajete reads the chalked card
from a photograph handed to a persisted firing log. `ask` takes `with:`
the PNG.

**What it teaches**

- `ask` on a persisted chat accepts `with:` a local photograph.
- The user row is saved. The request carries `data:image/png;base64`.
- Without Active Storage the blob is not an association. The file still goes out on that first ask.

**Files**

| File | Role |
| --- | --- |
| [`firing_plate.rb`](firing_plate.rb) | Creates the firing log and asks with the photograph |
| [`firing_plate_test.rb`](firing_plate_test.rb) | Replays the cassette and checks the soak, the pressure, and the image part |
| [`kiln-card.png`](kiln-card.png) | The posted Tilcajete kiln card |
| [`cassettes/firing_plate.yml`](cassettes/firing_plate.yml) | The Chat Completions round-trip with the image |

**Sample file**

`kiln-card.png` was drawn for this catalog with Pillow and DejaVu Sans.
The words and the figures are original. No third-party photograph was
copied.

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/03-oaxaca-alebrije-plate/firing_plate.rb
bundle exec ruby features/10-rails-integration/03-oaxaca-alebrije-plate/firing_plate_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after a live
OpenRouter `:free` probe returned empty content. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/03-oaxaca-alebrije-plate/firing_plate.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 16 October 2026.
