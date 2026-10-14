# Image generation · 06 · Friday Harbor blue hour prompt

The berth desk at Friday Harbor wants a blue-hour plate of the floats, with
slip 14 holding the packet Orcas. The clerk logs `revised_prompt` onto the
card. On `gpt-image-1-mini` that reader is `nil`.

**What it teaches**

- `image.revised_prompt` is the provider's rewritten prompt when one is
  reported, otherwise `nil`.
- DALL-E 3 used to fill this reader. It was gone from OpenAI's models list
  on 14 October 2026. This cassette's response has no `revised_prompt` key.
- The request body is the desk's original copy, including slip 14 and Orcas.

**Files**

| File | Role |
| --- | --- |
| [`blue_hour.rb`](blue_hour.rb) | Paints the floats and reads revised_prompt |
| [`blue_hour_test.rb`](blue_hour_test.rb) | Replays the cassette |
| [`cassettes/blue_hour.yml`](cassettes/blue_hour.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/07-image-generation/06-friday-harbor-blue-hour-prompt/blue_hour_test.rb
```

**Model**

`gpt-image-1-mini`. `revised_prompt` stays nil.
