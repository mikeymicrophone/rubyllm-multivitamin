# Multimodal attachments · 02 · New Dungeness lens drawer

The lens keeper at New Dungeness reads a small cabinet label: drawer 4,
bullseye prism, focal length 375 mm. The label is an attachment built
with `resolution: :high`.

**What it teaches**

- `RubyLLM::Attachment.new` takes `resolution:`.
- `:high` is sent as `"detail":"high"` on the `input_image` part.
- `with:` accepts that attachment object.

**Files**

| File | Role |
| --- | --- |
| [`drawer_label.rb`](drawer_label.rb) | Builds the high-detail attachment and asks |
| [`drawer_label_test.rb`](drawer_label_test.rb) | Replays the cassette and checks the detail field |
| [`drawer-label.png`](drawer-label.png) | The cabinet label |
| [`cassettes/drawer_label.yml`](cassettes/drawer_label.yml) | The Responses round-trip |

**Sample file**

`drawer-label.png` was drawn for this catalog with ImageMagick and DejaVu
Sans. The label copy is original. The cassette stores the PNG as base64.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/02-new-dungeness-lens-drawer/drawer_label.rb
bundle exec ruby features/05-multimodal-attachments/02-new-dungeness-lens-drawer/drawer_label_test.rb
```

The cassette is a live recording of `gpt-4.1-mini`. Re-record it with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/02-new-dungeness-lens-drawer/drawer_label.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Preferred free slug when the daily cap allows
it: `google/gemma-4-31b-it:free`.
