# Image generation · 05 · Anacortes retort floor plate

The cannery clerk at Anacortes binds a documentary plate of retort 2 into
the cook book. The binder wants JPEG. `provider_options` asks for jpeg;
`mime_type` still reads `"image/png"`.

**What it teaches**

- `provider_options: { output_format: "jpeg" }` is merged onto the payload
  beside `quality: "low"`.
- `Image#mime_type` is `"image/png"` even when the bytes are JPEG.
  RubyLLM's OpenAI image parser hardcodes that MIME type.
- `to_blob` starts with JPEG magic (`\\xFF\\xD8\\xFF`).

**Files**

| File | Role |
| --- | --- |
| [`retort_plate.rb`](retort_plate.rb) | Paints retort 2 as JPEG |
| [`retort_plate_test.rb`](retort_plate_test.rb) | Replays the cassette |
| [`cassettes/retort_plate.yml`](cassettes/retort_plate.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/07-image-generation/05-anacortes-retort-floor-plate/retort_plate_test.rb
```

The cassette stores a 1×1 JPEG stand-in for `b64_json`, so replay still
starts with JPEG magic.

**Model**

`gpt-image-1-mini`, `output_format: "jpeg"`, `quality: "low"`.
