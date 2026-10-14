# Streaming · 10 · Anacortes cannery lot code

The label clerk at the Anacortes cannery streams the morning cook's lot
code, `ANC-2026-1014-R2-B3`, for basket 3 on retort No. 2. The stream can
flush in the middle of that code. The label is the joined chunks.

**What it teaches**

- A lot code is read from the joined `content`, which equals the message
  `ask` returns. This recording splits `ANC-2026-1014-R2-B3` so no piece
  holds the whole code.
- `Basket 3` in this cassette uses a normal space. The assertion still
  uses `[[:space:]]`, because the same model puts U+202F beside a number
  on other boards. That character is in the Point Wilson tide dictation.

**Files**

| File | Role |
| --- | --- |
| [`lot_code.rb`](lot_code.rb) | Streams the label and keeps the pieces |
| [`lot_code_test.rb`](lot_code_test.rb) | Replays the cassette and reads the code from the join |
| [`cassettes/lot_code.yml`](cassettes/lot_code.yml) | The streamed label |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/10-anacortes-cannery-lot-code/lot_code.rb
bundle exec ruby features/02-streaming/10-anacortes-cannery-lot-code/lot_code_test.rb
```

Both commands replay the cassette. No API key is required. The script also
prints each piece so the flush in the middle of the code is visible.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`.
Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/02-streaming/10-anacortes-cannery-lot-code/lot_code_test.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
