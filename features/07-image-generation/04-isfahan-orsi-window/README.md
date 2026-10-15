# Image generation · 04 · Isfahan orsi window

The restoration atelier in Jolfa needs a plate of a Safavid orsi window
delivered as bytes. The workshop PCs have no outbound HTTP, so a hosted
URL would be useless. `gpt-image-1-mini` returns inline Base64.

**What it teaches**

- `Image#url` is `nil` when the provider returns inline bytes.
- `Image#base64?` is true and `Image#data` holds the Base64 payload.
- The request does not send `response_format`. That parameter is unknown
  on this model.

**Files**

| File | Role |
| --- | --- |
| [`orsi_window.rb`](orsi_window.rb) | Paints the orsi and reads url / base64? |
| [`orsi_window_test.rb`](orsi_window_test.rb) | Replays the cassette |
| [`cassettes/orsi_window.yml`](cassettes/orsi_window.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/07-image-generation/04-isfahan-orsi-window/orsi_window_test.rb
```

**Model**

`gpt-image-1-mini`. The cassette response contains `b64_json` and no hosted
`url`.
