# Multimodal attachments · 08 · Smith Island barometer round

The weather watch at Smith Island has the barometer photograph for 06:00
and the written round, which still has the 04:00 glass and the wind.
One question carries both.

**What it teaches**

- `with:` mixes an image path and a text path.
- The image is an `input_image` data URI.
- The text file is a text part wrapped as
  `<file name='weather-round.txt' mime_type='text/plain'>`.
- The reply uses a figure from each file.

**Files**

| File | Role |
| --- | --- |
| [`barometer_round.rb`](barometer_round.rb) | Asks with the photograph and the written round |
| [`barometer_round_test.rb`](barometer_round_test.rb) | Replays the cassette and checks both parts |
| [`barometer-glass.png`](barometer-glass.png) | The 06:00 glass |
| [`weather-round.txt`](weather-round.txt) | The written round |
| [`cassettes/barometer_round.yml`](cassettes/barometer_round.yml) | The Responses round-trip |

**Sample files**

The PNG was drawn for this catalog with ImageMagick and DejaVu Sans.
The text file was written for this catalog. Both are original. The
cassette stores the PNG as base64. The text file is plain in the body.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/08-smith-island-barometer/barometer_round.rb
bundle exec ruby features/05-multimodal-attachments/08-smith-island-barometer/barometer_round_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/08-smith-island-barometer/barometer_round.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Preferred free slug when the daily cap allows
it: `google/gemma-4-31b-it:free`. A text file alone can ride with any
chat model. The photograph is why this one is a vision model.
