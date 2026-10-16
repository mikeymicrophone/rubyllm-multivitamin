# Files · 12 · Medan durian lot

The stall clerk in Medan stores a CSV lot sheet and finds it by id.
Row MDN-2026-1016-D9 still opens at 07:25. OpenAI will not download
`user_data`; that refusal is the Valparaíso card. A Mistral-generated
CSV needs a key this catalog does not have.

**What it teaches**

- A CSV uploads as `user_data`.
- `find` reloads filename and byte_size.
- Download of `user_data` is slot 04.

**Files**

| File | Role |
| --- | --- |
| [`durian_lot.rb`](durian_lot.rb) | Uploads and finds the CSV |
| [`durian_lot_test.rb`](durian_lot_test.rb) | Checks the filename |
| [`durian-lot.csv`](durian-lot.csv) | The stall sheet |
| [`cassettes/durian_lot.yml`](cassettes/durian_lot.yml) | POST then GET metadata |

**Try it**

```sh
bundle exec ruby features/26-files/12-medan-durian-lot/durian_lot.rb
bundle exec ruby features/26-files/12-medan-durian-lot/durian_lot_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
