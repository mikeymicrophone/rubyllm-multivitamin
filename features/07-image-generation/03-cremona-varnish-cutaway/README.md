# Image generation · 03 · Cremona varnish cutaway

The varnish keeper at Atelier Guadagnini in Cremona files a cutaway of
drawer 3 beside the inventory card. `save` writes the inline bytes and
returns the path.

**What it teaches**

- `Image#save` writes a file from inline Base64 and returns the path given.
- The magic bytes are PNG (`\\x89PNG`) when `output_format` is left at png.
- `base64?` is true, so `save` does not GET a hosted URL. The cassette has
  one HTTP interaction.

**Files**

| File | Role |
| --- | --- |
| [`varnish_cutaway.rb`](varnish_cutaway.rb) | Paints drawer 3 and saves the cutaway |
| [`varnish_cutaway_test.rb`](varnish_cutaway_test.rb) | Replays the cassette and checks the PNG header |
| [`cassettes/varnish_cutaway.yml`](cassettes/varnish_cutaway.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/07-image-generation/03-cremona-varnish-cutaway/varnish_cutaway_test.rb
```

Re-record with `LIVE=1 LIVE_PROVIDER=openai`. Large `b64_json` is replaced
with a 1×1 PNG stand-in; the magic bytes stay PNG.

**Model**

`gpt-image-1-mini`, `size: "1024x1024"`, `quality: "low"`.
