# Files · 10 · Sokoto calabash ridge

The ridge clerk in Sokoto stores a drying note and forgets `purpose:`.
OpenAI answers HTTP 400. That is not a local `ArgumentError`. Vertex
`gs://` needs a project this catalog does not have.

**What it teaches**

- OpenAI requires `purpose:` on the wire.
- The error is `RubyLLM::BadRequestError`.
- The cassette is that 400.

**Files**

| File | Role |
| --- | --- |
| [`calabash_ridge.rb`](calabash_ridge.rb) | Uploads without `purpose:` |
| [`calabash_ridge_test.rb`](calabash_ridge_test.rb) | Checks the 400 |
| [`ridge-note.txt`](ridge-note.txt) | The drying note |
| [`cassettes/calabash_ridge.yml`](cassettes/calabash_ridge.yml) | The Files 400 |

**Try it**

```sh
bundle exec ruby features/26-files/10-sokoto-calabash-ridge/calabash_ridge.rb
bundle exec ruby features/26-files/10-sokoto-calabash-ridge/calabash_ridge_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
