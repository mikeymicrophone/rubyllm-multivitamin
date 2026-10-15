# Text to speech · 11 · McCurdy Point save vs to_blob

The spit clerk at McCurdy Point writes the kelp-ledge hail to a file and
also hands the raw bytes to the VHF desk, and those two must match.

**What it teaches**

- `Speech#to_blob` returns the same bytes `save` writes.
- `save` returns the path.
- Both read the inline audio. Neither GETs a URL. One HTTP call.

**Files**

| File | Role |
| --- | --- |
| [`mccurdy_blob.rb`](mccurdy_blob.rb) | Speaks, saves, and compares the bytes |
| [`mccurdy_blob_test.rb`](mccurdy_blob_test.rb) | Replays the cassette |
| [`cassettes/mccurdy_blob.yml`](cassettes/mccurdy_blob.yml) | Live OpenAI recording of `tts-1` |

**Try it**

```sh
bundle exec ruby features/17-text-to-speech/11-mccurdy-point-save-blob/mccurdy_blob_test.rb
```

Re-record with `LIVE=1 LIVE_PROVIDER=openai`. Do not hand-author the cassette.

**Model**

Recorded on `tts-1` with `provider: :openai`.
