# Tokens and cost · 08 · Bush Point flood-table stream usage

The current clerk at Bush Point on west Whidbey dictates the flood table
for the kelp skiff Mutiny. Usage is requested on the stream. The counts
land on the last chunk, and that last chunk matches the message.

**What it teaches**

- A streamed `ask` sends `stream_options.include_usage`.
- `chunk.tokens` stays nil until the last chunk. An earlier chunk can
  already carry `finish_reason` with nil input tokens.
- The returned message's tokens and `cost.total` match that last chunk.

**Files**

| File | Role |
| --- | --- |
| [`flood_table.rb`](flood_table.rb) | Streams the flood table and records each chunk's usage |
| [`flood_table_test.rb`](flood_table_test.rb) | Replays the cassette and checks the last chunk |
| [`cassettes/flood_table.yml`](cassettes/flood_table.yml) | The streamed Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/08-bush-point-flood-table/flood_table.rb
bundle exec ruby features/12-tokens-and-cost/08-bush-point-flood-table/flood_table_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/08-bush-point-flood-table/flood_table.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 15 October 2026.
