# Multimodal attachments · 05 · Magelang Borobudur sheet

The survey desk at Magelang keeps one photograph the office already
trusts. The question passes that URL. It does not pass a path a visitor
typed in.

**What it teaches**

- `with:` accepts an `https` URL.
- The Responses request forwards that URL on `input_image`. The bytes
  are not inlined, because the filename ends in `.jpg`.
- The URL is a constant in this folder. Attachment strings are
  instructions to fetch. This scenario does not take one from a caller.

**Files**

| File | Role |
| --- | --- |
| [`borobudur_sheet.rb`](borobudur_sheet.rb) | Asks about the trusted sheet |
| [`borobudur_sheet_test.rb`](borobudur_sheet_test.rb) | Replays the cassette and checks the URL is not a data URI |
| [`cassettes/borobudur_sheet.yml`](cassettes/borobudur_sheet.yml) | The Responses round-trip |

**Sample**

The sheet is a public-domain photograph of Borobudur hosted as
[File:Borobudur Temple.jpg](https://commons.wikimedia.org/wiki/File:Borobudur_Temple.jpg)
on Wikimedia Commons. This folder does not copy the JPEG. The cassette
stores the URL.

A Wikimedia thumbnail URL (`/thumb/.../320px-...`) failed in a probe
with `Error while downloading file`. The original file URL is the one
this scenario uses.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/05-magelang-borobudur-sheet/borobudur_sheet.rb
bundle exec ruby features/05-multimodal-attachments/05-magelang-borobudur-sheet/borobudur_sheet_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/05-magelang-borobudur-sheet/borobudur_sheet.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Preferred free slug when the daily cap allows
it: `google/gemma-4-31b-it:free`.
