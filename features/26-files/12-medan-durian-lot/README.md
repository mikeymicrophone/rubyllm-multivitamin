# Files · 12 · Medan durian lot

The stall clerk in Medan stores a CSV lot sheet and downloads it again.
Row MDN-2026-1016-D9 still opens at 07:25. A Mistral-generated CSV needs
a key this catalog does not have.

**What it teaches**

- A CSV uploads as `user_data`.
- The download is the same rows, not a generated file.
- `DownloadedFile` is a String.

**Files**

| File | Role |
| --- | --- |
| [`durian_lot.rb`](durian_lot.rb) | Uploads and downloads the CSV |
| [`durian_lot_test.rb`](durian_lot_test.rb) | Checks the lot code |
| [`durian-lot.csv`](durian-lot.csv) | The stall sheet |
| [`cassettes/durian_lot.yml`](cassettes/durian_lot.yml) | POST then GET content |

**Try it**

```sh
bundle exec ruby features/26-files/12-medan-durian-lot/durian_lot.rb
bundle exec ruby features/26-files/12-medan-durian-lot/durian_lot_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
