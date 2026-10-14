# Image generation · 11 · Port Townsend slip blob

The slip clerk at Port Townsend writes the crosswind plate to a file and
hands the same bytes to the printer. `to_blob` and `save` must match.

**What it teaches**

- `Image#to_blob` returns the decoded inline bytes.
- `save` writes those same bytes. `File.binread` of the path equals `to_blob`.
- On `gpt-image-1-mini` neither call GETs a URL. The cassette has one
  interaction.

**Files**

| File | Role |
| --- | --- |
| [`slip_blob.rb`](slip_blob.rb) | Paints the slip, saves, and reads to_blob |
| [`slip_blob_test.rb`](slip_blob_test.rb) | Replays the cassette |
| [`cassettes/slip_blob.yml`](cassettes/slip_blob.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/07-image-generation/11-port-townsend-slip-blob/slip_blob_test.rb
```

**Model**

`gpt-image-1-mini`.
