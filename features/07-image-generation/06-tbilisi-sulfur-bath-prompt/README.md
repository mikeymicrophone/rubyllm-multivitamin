# Image generation · 06 · Tbilisi sulfur-bath prompt

The bath desk at Abanotubani wants a blue-hour plate of the brick domes
and files whether the provider rewrote the prompt. Lighting copy has to
stay; a postcard rewrite would lose Bath 4 and the night fireman.

**What it teaches**

- `Image#revised_prompt` is the provider's rewrite when one is reported.
- `gpt-image-1-mini` does not rewrite. `revised_prompt` is `nil`.
- The original prompt is the one on the wire.

**Files**

| File | Role |
| --- | --- |
| [`sulfur_bath.rb`](sulfur_bath.rb) | Paints the baths and reads revised_prompt |
| [`sulfur_bath_test.rb`](sulfur_bath_test.rb) | Replays the cassette |
| [`cassettes/sulfur_bath.yml`](cassettes/sulfur_bath.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/07-image-generation/06-tbilisi-sulfur-bath-prompt/sulfur_bath_test.rb
```

**Model**

`gpt-image-1-mini`. The cassette response has no `revised_prompt` key.
