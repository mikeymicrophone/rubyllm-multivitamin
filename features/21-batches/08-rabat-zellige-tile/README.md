# Batches · 08 · Rabat zellige-tile cancel

The tile clerk in Rabat files 40 zellige stars for Imane, then cancels
the unfinished batch.

**What it teaches**

- `batch.cancel` asks the provider to stop an unfinished batch.
- `raw_status` shows cancelling or cancelled. Already-finished requests still return.

**Files**

| File | Role |
| --- | --- |
| [`zellige_tile.rb`](zellige_tile.rb) | Submits the tile card and cancels immediately |
| [`zellige_tile_test.rb`](zellige_tile_test.rb) | Replays the cassette and checks raw_status |
| [`cassettes/zellige_tile.yml`](cassettes/zellige_tile.yml) | Upload, create, and cancel |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/21-batches/08-rabat-zellige-tile/zellige_tile.rb
bundle exec ruby features/21-batches/08-rabat-zellige-tile/zellige_tile_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/21-batches/08-rabat-zellige-tile/zellige_tile.rb
```

**Model**

OpenAI Batch on `gpt-4.1-mini`. Free OpenRouter slugs usually have no batch access. Checked 16 October 2026.
