# Tools · 03 · Cape Disappointment compressor

The foghorn watch at Cape Disappointment reads 92 psi on the compressor
gauge. The posted minimum is not in the question. `parameter` tells the
model the gauge is a number and the station is a string, both required.

**What it teaches**

- `parameter` sets `type`, `description`, and `required: true`.
- `:number` is `"number"` in the schema. `:string` stays `"string"`.
- Both names are listed in `required`, in declaration order.
- The tool compares the gauge with 85 psi and returns a sentence. The
  answer has to include that minimum.
- The first request carries the schema and does not carry `85`.

**Files**

| File | Role |
| --- | --- |
| [`compressor_card.rb`](compressor_card.rb) | Declares the gauge parameters and asks the watch question |
| [`compressor_card_test.rb`](compressor_card_test.rb) | Checks the schema locally and the cassette when it exists |
| [`cassettes/compressor_card.yml`](cassettes/compressor_card.yml) | Not recorded yet |

**Try it**

The cassette is not recorded. The chat test skips with `cassette pending
live recording`.

```sh
bundle exec ruby features/03-tools/03-cape-disappointment-compressor/compressor_card_test.rb
```

Record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/03-tools/03-cape-disappointment-compressor/compressor_card_test.rb
```

Do not hand-author the cassette.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
