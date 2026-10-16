# Files · 04 · Valparaíso funicular

The car clerk on the Artillería funicular in Valparaíso stores the trip
card, finds it by id, and downloads the bytes. Mateo still rides at 07:15.

**What it teaches**

- `UploadedFile.find` reloads metadata by provider file id.
- `RubyLLM.download` returns a `DownloadedFile`. `save` writes the bytes.
- Persist the provider alongside the id.

**Files**

| File | Role |
| --- | --- |
| [`funicular_card.rb`](funicular_card.rb) | Uploads, finds, downloads |
| [`funicular_card_test.rb`](funicular_card_test.rb) | Checks the round-trip |
| [`funicular-card.pdf`](funicular-card.pdf) | The trip card |
| [`cassettes/funicular_card.yml`](cassettes/funicular_card.yml) | POST, GET metadata, GET content |

**Try it**

```sh
bundle exec ruby features/26-files/04-valparaiso-funicular/funicular_card.rb
bundle exec ruby features/26-files/04-valparaiso-funicular/funicular_card_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
