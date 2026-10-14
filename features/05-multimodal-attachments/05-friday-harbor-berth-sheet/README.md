# Multimodal attachments · 05 · Friday Harbor berth sheet

The berth desk at Friday Harbor keeps one map sheet the harbormaster
already trusts. The question passes that URL. It does not pass a path
a visitor typed in.

**What it teaches**

- `with:` accepts an `https` URL.
- The Responses request forwards that URL on `input_image`. The bytes
  are not inlined, because the filename ends in `.jpg`.
- The URL is a constant in this folder. Attachment strings are
  instructions to fetch. This scenario does not take one from a caller.

**Files**

| File | Role |
| --- | --- |
| [`berth_sheet.rb`](berth_sheet.rb) | Asks about the trusted sheet |
| [`berth_sheet_test.rb`](berth_sheet_test.rb) | Replays the cassette and checks the URL is not a data URI |
| [`cassettes/berth_sheet.yml`](cassettes/berth_sheet.yml) | The Responses round-trip |

**Sample**

The sheet is the public-domain US Army Map Service drawing of Friday
Harbor, Washington, hosted as
[File:Friday Harbor Washington.jpg](https://commons.wikimedia.org/wiki/File:Friday_Harbor_Washington.jpg)
on Wikimedia Commons. This folder does not copy the JPEG. The cassette
stores the URL.

A Wikimedia thumbnail URL (`/thumb/.../320px-...`) failed in a probe
with `Error while downloading file`. The original file URL is the one
this scenario uses.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/05-friday-harbor-berth-sheet/berth_sheet.rb
bundle exec ruby features/05-multimodal-attachments/05-friday-harbor-berth-sheet/berth_sheet_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/05-friday-harbor-berth-sheet/berth_sheet.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Preferred free slug when the daily cap allows
it: `google/gemma-4-31b-it:free`.
