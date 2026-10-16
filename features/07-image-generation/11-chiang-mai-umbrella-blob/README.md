# Image generation · 11 · Chiang Mai umbrella blob

The workshop clerk at Bo Sang writes the lotus-umbrella plate to a file
and hands the same bytes to the woodblock printer. `to_blob` and `save`
must match.

**What it teaches**

- `Image#to_blob` returns the decoded inline bytes.
- `save` writes those same bytes. `File.binread` of the path equals `to_blob`.
- On `gpt-image-1-mini` neither call GETs a URL. The cassette has one
  interaction.

**Files**

| File | Role |
| --- | --- |
| [`umbrella_blob.rb`](umbrella_blob.rb) | Paints the umbrella, saves, and reads to_blob |
| [`umbrella_blob_test.rb`](umbrella_blob_test.rb) | Replays the cassette |
| [`cassettes/umbrella_blob.yml`](cassettes/umbrella_blob.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/07-image-generation/11-chiang-mai-umbrella-blob/umbrella_blob_test.rb
```

**Model**

`gpt-image-1-mini`.
