# Multimodal attachments · 06 · Luang Prabang mural

The mural painter at Wat Xieng Thong looks at the west wall, then at the
cracked panel. One question carries both photographs.

**What it teaches**

- `with:` takes an array of images in one `ask`.
- Each image becomes its own `input_image` part, in that order.
- The reply has to use both photographs, not only the first.

**Files**

| File | Role |
| --- | --- |
| [`wat_mural.rb`](wat_mural.rb) | Asks with the wall and the cracked panel |
| [`wat_mural_test.rb`](wat_mural_test.rb) | Replays the cassette and counts two image parts |
| [`mural-wall.png`](mural-wall.png) | Twelve panels |
| [`panel-five.png`](panel-five.png) | The cracked panel |
| [`cassettes/wat_mural.yml`](cassettes/wat_mural.yml) | The Responses round-trip |

**Sample files**

Both PNGs were drawn for this catalog with ImageMagick and DejaVu Sans.
The words are original.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/06-luang-prabang-mural/wat_mural.rb
bundle exec ruby features/05-multimodal-attachments/06-luang-prabang-mural/wat_mural_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/06-luang-prabang-mural/wat_mural.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Preferred free slug when the daily cap allows
it: `google/gemma-4-31b-it:free`.
