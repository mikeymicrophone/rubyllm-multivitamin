# Files · 02 · Nelson hops kiln

The kiln clerk in Nelson stores a jsonl mill sheet with `purpose: "batch"`.
That does not start a batch. It only parks the sheet for a later mill run.

**What it teaches**

- OpenAI requires `purpose:`. `"batch"` is the mill-sheet purpose.
- `filename` and `byte_size` come back on the `UploadedFile`.
- This slot does not call `RubyLLM.batch`.

**Files**

| File | Role |
| --- | --- |
| [`hops_kiln.rb`](hops_kiln.rb) | Uploads the jsonl |
| [`hops_kiln_test.rb`](hops_kiln_test.rb) | Checks purpose and size |
| [`hops-batch.jsonl`](hops-batch.jsonl) | One kiln line |
| [`cassettes/hops_kiln.yml`](cassettes/hops_kiln.yml) | The Files POST |

**Try it**

```sh
bundle exec ruby features/26-files/02-nelson-hops-kiln/hops_kiln.rb
bundle exec ruby features/26-files/02-nelson-hops-kiln/hops_kiln_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
