# Multimodal attachments · 01 · Point Wilson tide board

The incoming watch at Point Wilson reads the chalked tide board from a
photograph. The heights are not typed into the question.

**What it teaches**

- `ask` takes a local image path with `with:`.
- RubyLLM detects `image/png` and sends an `input_image` data URI. The
  script does not set a MIME type.
- The reply is a `RubyLLM::Message`. `finish_reason`, token counts, and
  `cost.total` are read off it.

**Files**

| File | Role |
| --- | --- |
| [`tide_board.rb`](tide_board.rb) | Asks gpt-4.1-mini about the photograph |
| [`tide_board_test.rb`](tide_board_test.rb) | Replays the cassette and checks the heights, the image part, and the key filter |
| [`tide-board.png`](tide-board.png) | The chalked board |
| [`cassettes/tide_board.yml`](cassettes/tide_board.yml) | The Responses round-trip |

**Sample file**

`tide-board.png` was drawn for this catalog with ImageMagick and DejaVu
Sans. The words and the figures are original. No third-party photograph
was copied.

The cassette stores the PNG as base64 inside the request. The file is
about 8 KB; the data URI is the bulk of the cassette.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/01-point-wilson-tide-board/tide_board.rb
bundle exec ruby features/05-multimodal-attachments/01-point-wilson-tide-board/tide_board_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI. The free
OpenRouter vision slug was past its daily cap when this was bottled. See
the [feature README](../README.md). Re-record it with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/01-point-wilson-tide-board/tide_board.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. The preferred free slug, when the daily cap
allows it, is `google/gemma-4-31b-it:free`.
