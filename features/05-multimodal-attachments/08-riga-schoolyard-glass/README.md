# Multimodal attachments · 08 · Riga schoolyard glass

The science teacher on a Riga schoolyard round has a photograph of the
glass at 08:00 and a written round that still holds 06:00. One question
carries both files.

**What it teaches**

- One `ask` can mix an image and a text file.
- A text file is a text part wrapped as a file element, not an image.
- The reply has to use the photograph and the written round.

**Files**

| File | Role |
| --- | --- |
| [`schoolyard_round.rb`](schoolyard_round.rb) | Asks with the glass and the written round |
| [`schoolyard_round_test.rb`](schoolyard_round_test.rb) | Replays the cassette and checks both parts |
| [`schoolyard-glass.png`](schoolyard-glass.png) | The 08:00 reading |
| [`schoolyard-round.txt`](schoolyard-round.txt) | The written round |
| [`cassettes/schoolyard_round.yml`](cassettes/schoolyard_round.yml) | The Responses round-trip |

**Sample files**

The PNG was drawn for this catalog with ImageMagick and DejaVu Sans.
The text file is original.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/08-riga-schoolyard-glass/schoolyard_round.rb
bundle exec ruby features/05-multimodal-attachments/08-riga-schoolyard-glass/schoolyard_round_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/08-riga-schoolyard-glass/schoolyard_round.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Preferred free slug when the daily cap allows
it: `google/gemma-4-31b-it:free`.
