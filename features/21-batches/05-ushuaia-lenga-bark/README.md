# Batches · 05 · Ushuaia lenga-bark embed_later

The bark clerk in Ushuaia stages two lenga-stack notes with `embed_later`
and files them as one embedding batch.

**What it teaches**

- `RubyLLM.embed_later` stages a text without contacting the provider.
- `RubyLLM.batch` accepts embedding requests. `results` stay `nil` until complete.

**Files**

| File | Role |
| --- | --- |
| [`lenga_bark.rb`](lenga_bark.rb) | Stages two bark notes and submits the embedding batch |
| [`lenga_bark_test.rb`](lenga_bark_test.rb) | Replays the cassette and checks the request count |
| [`cassettes/lenga_bark.yml`](cassettes/lenga_bark.yml) | Embedding JSONL upload and batch create |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/21-batches/05-ushuaia-lenga-bark/lenga_bark.rb
bundle exec ruby features/21-batches/05-ushuaia-lenga-bark/lenga_bark_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/21-batches/05-ushuaia-lenga-bark/lenga_bark.rb
```

**Model**

OpenAI Batch on `text-embedding-3-small`. Checked 16 October 2026.
