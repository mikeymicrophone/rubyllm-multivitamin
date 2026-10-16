# Files · 07 · Ayacucho retablo lot

The retablo clerk in Ayacucho uploads the lot card once and asks twice
with the same `UploadedFile`. Rosa packs 12 boxes at 10:05. Anthropic
reuse needs a key this catalog does not have.

**What it teaches**

- One upload serves two asks.
- The second `with:` is the same file id.
- The cassette is Files once, then two Responses.

**Files**

| File | Role |
| --- | --- |
| [`retablo_lot.rb`](retablo_lot.rb) | Uploads, then asks twice |
| [`retablo_lot_test.rb`](retablo_lot_test.rb) | Checks 12 and 10:05 |
| [`retablo-lot.pdf`](retablo-lot.pdf) | The lot card |
| [`cassettes/retablo_lot.yml`](cassettes/retablo_lot.yml) | Files then two Responses |

**Try it**

```sh
bundle exec ruby features/26-files/07-ayacucho-retablo-lot/retablo_lot.rb
bundle exec ruby features/26-files/07-ayacucho-retablo-lot/retablo_lot_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
