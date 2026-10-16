# Files · 11 · Ghent bobbin lace

The pillow clerk in Ghent stores the Lille-ground lot as a batch jsonl
and downloads it again. The bytes still name pillow GNT-2026-1016-L6.
OpenAI will not download `user_data`; `purpose: "batch"` will.

**What it teaches**

- `DownloadedFile` is a String. `to_blob` is the same bytes.
- A `batch` jsonl is downloadable on OpenAI. A `user_data` PDF is not.
- The mill copy survives the round-trip.

**Files**

| File | Role |
| --- | --- |
| [`bobbin_lace.rb`](bobbin_lace.rb) | Uploads and downloads |
| [`bobbin_lace_test.rb`](bobbin_lace_test.rb) | Checks the pillow code |
| [`lace-lot.jsonl`](lace-lot.jsonl) | The pillow lot |
| [`cassettes/bobbin_lace.yml`](cassettes/bobbin_lace.yml) | POST then GET content |

**Try it**

```sh
bundle exec ruby features/26-files/11-ghent-bobbin-lace/bobbin_lace.rb
bundle exec ruby features/26-files/11-ghent-bobbin-lace/bobbin_lace_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
