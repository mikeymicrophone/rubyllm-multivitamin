# Tools · 09 · Bremerton dry dock sill

The repair barge Kulshan is waiting on the tide. The first sentence of
the question names the barge. Bremerton shows up later. The sill card
for that station is 38 ft, and that depth is not in the question.

**What it teaches**

- The model has to pass `station:` from a later sentence, not from the
  opening line.
- The tool returns the sill card only when the station matches Bremerton.
- The depth `38` is on the tool message and in the answer.

**Files**

| File | Role |
| --- | --- |
| [`sill_depth.rb`](sill_depth.rb) | Asks for the sill and reads the Bremerton card |
| [`sill_depth_test.rb`](sill_depth_test.rb) | Checks the question locally and the cassette when it exists |
| [`cassettes/sill_depth.yml`](cassettes/sill_depth.yml) | Not recorded yet |

**Try it**

The cassette is not recorded. The chat test skips with `cassette pending
live recording`.

```sh
bundle exec ruby features/03-tools/09-bremerton-dry-dock-sill/sill_depth_test.rb
```

Record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/03-tools/09-bremerton-dry-dock-sill/sill_depth_test.rb
```

Do not hand-author the cassette.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
