# Multimodal attachments · 02 · Lviv linotype label

The compositor in a Lviv linotype shop reads a small magazine label:
magazine 6, 8-point Garamond. The label is handed over as an attachment
with `resolution: :high` so the point size survives.

**What it teaches**

- Build a `RubyLLM::Attachment` when the call needs `resolution:`.
- `:high` asks the provider for the finer image detail.
- The attachment object is what `with:` receives. A path is not required.

**Files**

| File | Role |
| --- | --- |
| [`magazine_label.rb`](magazine_label.rb) | Asks with `resolution: :high` |
| [`magazine_label_test.rb`](magazine_label_test.rb) | Replays the cassette and checks `"detail":"high"` |
| [`magazine-label.png`](magazine-label.png) | The small brass label |
| [`cassettes/magazine_label.yml`](cassettes/magazine_label.yml) | The Responses round-trip |

**Sample file**

`magazine-label.png` was drawn for this catalog with ImageMagick and DejaVu
Sans. The words and the figures are original.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/02-lviv-linotype-label/magazine_label.rb
bundle exec ruby features/05-multimodal-attachments/02-lviv-linotype-label/magazine_label_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/02-lviv-linotype-label/magazine_label.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Preferred free slug when the daily cap allows
it: `google/gemma-4-31b-it:free`.
