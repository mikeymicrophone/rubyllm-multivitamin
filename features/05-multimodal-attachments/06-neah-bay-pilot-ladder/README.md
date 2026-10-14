# Multimodal attachments · 06 · Neah Bay pilot ladder

The pilot at Neah Bay looks at two photographs in one question: the
ladder against the ship's side, and the close-up of rung 7.

**What it teaches**

- `with:` takes an array of image paths.
- Each path becomes its own `input_image` part, in that order.
- The reply has to use both photographs.

**Files**

| File | Role |
| --- | --- |
| [`pilot_ladder.rb`](pilot_ladder.rb) | Asks about both photographs |
| [`pilot_ladder_test.rb`](pilot_ladder_test.rb) | Replays the cassette and counts the image parts |
| [`ladder-side.png`](ladder-side.png) | The ladder against the ship |
| [`rung-seven.png`](rung-seven.png) | The cracked rung |
| [`cassettes/pilot_ladder.yml`](cassettes/pilot_ladder.yml) | The Responses round-trip |

**Sample files**

Both PNGs were drawn for this catalog with ImageMagick and DejaVu Sans.
The copy is original. The cassette holds both images as base64, so it
is about twice a single-image cassette.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/06-neah-bay-pilot-ladder/pilot_ladder.rb
bundle exec ruby features/05-multimodal-attachments/06-neah-bay-pilot-ladder/pilot_ladder_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/06-neah-bay-pilot-ladder/pilot_ladder.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Preferred free slug when the daily cap allows
it: `google/gemma-4-31b-it:free`.
