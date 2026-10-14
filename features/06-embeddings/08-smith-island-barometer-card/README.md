# Embeddings · 08 · Smith Island barometer card

The weather watch at Smith Island embeds the photographed barometer glass
with a one-line caption. The vision embedding model returns a 768-wide
vector. `text-embedding-3-small` refuses the PNG before a request is sent.

**What it teaches**

- `with:` on `RubyLLM.embed` sends one text plus attachments. An array of
  texts with `with:` raises `ArgumentError`.
- OpenRouter posts `{content: [{type: text}, {type: image_url}]}` and
  `dimensions`. This recording uses paid `google/gemini-embedding-2`
  because the free vision embedding slug was past the daily cap.
- OpenAI's embeddings protocol does not support media.
  `UnsupportedAttachmentError` is raised locally. The cassette has only
  the OpenRouter round-trip.

**Files**

| File | Role |
| --- | --- |
| [`barometer_card.rb`](barometer_card.rb) | Embeds the glass on Gemini |
| [`barometer_card_test.rb`](barometer_card_test.rb) | Replays the cassette |
| [`barometer-glass.png`](barometer-glass.png) | The photographed card, 29.84 in falling |
| [`cassettes/barometer_card.yml`](cassettes/barometer_card.yml) | Live OpenRouter recording of `google/gemini-embedding-2` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/08-smith-island-barometer-card/barometer_card_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenRouter:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/06-embeddings/08-smith-island-barometer-card/barometer_card_test.rb
```

`LIVE_PROVIDER` does not retarget this example. The image call pins
`google/gemini-embedding-2`. Do not hand-author the cassette.

**Model**

Recorded on `google/gemini-embedding-2` with `provider: :openrouter`. Paid.
The free vision slug `nvidia/llama-nemotron-embed-vl-1b-v2:free` takes text
and image when the daily cap allows.
