# Files · 04 · Valparaíso funicular

The car clerk on the Artillería funicular in Valparaíso stores the trip
card and finds it by id. OpenAI will not download a `user_data` file.
Mateo still rides at 07:15.

**What it teaches**

- `UploadedFile.find` reloads metadata by provider file id.
- `RubyLLM.download` of `purpose: "user_data"` is HTTP 400.
- Persist the provider alongside the id.

**Files**

| File | Role |
| --- | --- |
| [`funicular_card.rb`](funicular_card.rb) | Uploads, finds, tries to download |
| [`funicular_card_test.rb`](funicular_card_test.rb) | Checks find and the 400 |
| [`funicular-card.pdf`](funicular-card.pdf) | The trip card |
| [`cassettes/funicular_card.yml`](cassettes/funicular_card.yml) | POST, GET metadata, GET content 400 |

**Try it**

```sh
bundle exec ruby features/26-files/04-valparaiso-funicular/funicular_card.rb
bundle exec ruby features/26-files/04-valparaiso-funicular/funicular_card_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
