# Image generation · 04 · Cape Disappointment foghorn house

The compressor shed at Cape Disappointment sits in a fog bank at the mouth
of the Columbia. `gpt-image-1-mini` returns the plate as inline Base64, not
as a hosted URL.

**What it teaches**

- `image.url` is `nil` on this model.
- `image.base64?` is true. `image.data` holds the Base64 payload.
- The cassette response contains `b64_json` and does not contain a hosted
  `url`. The request does not send `response_format`; that parameter is
  unknown on this model (a `BadRequestError` if you add it).

**Files**

| File | Role |
| --- | --- |
| [`foghorn_house.rb`](foghorn_house.rb) | Paints the horn house and reads url / base64? |
| [`foghorn_house_test.rb`](foghorn_house_test.rb) | Replays the cassette |
| [`cassettes/foghorn_house.yml`](cassettes/foghorn_house.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/07-image-generation/04-cape-disappointment-foghorn-house/foghorn_house_test.rb
```

**Model**

`gpt-image-1-mini`, `size: "1024x1024"`, `quality: "low"`. DALL-E 2/3, which
used to return URLs, were gone from OpenAI's models list on 14 October 2026.
