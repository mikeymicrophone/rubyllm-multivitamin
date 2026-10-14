# Tools · 04 · Anacortes retort cook book

The retort clerk at the Anacortes cannery has today's cook book open on
the bench. The tool is an instance that closes over that book. Basket 3
is sockeye, and the lot code is only in the book.

**What it teaches**

- `with_tools` accepts an instance. `initialize` keeps the cook book.
- `choice:` still accepts the class. RubyLLM finds the instance that
  `is_a?` that class.
- `parameter :basket, type: :integer` publishes `"type":"integer"`.
- The lot `ANC-1014-B3` is not in the question. The tool result carries
  it, and the answer repeats it.

**Files**

| File | Role |
| --- | --- |
| [`cook_card.rb`](cook_card.rb) | Builds the tool around today's book and asks about basket 3 |
| [`cook_card_test.rb`](cook_card_test.rb) | Checks the closed-over book locally and the cassette when it exists |
| [`cassettes/cook_card.yml`](cassettes/cook_card.yml) | Not recorded yet |

**Try it**

The cassette is not recorded. The chat test skips with `cassette pending
live recording`.

```sh
bundle exec ruby features/03-tools/04-anacortes-retort-cook-book/cook_card_test.rb
```

Record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/03-tools/04-anacortes-retort-cook-book/cook_card_test.rb
```

Do not hand-author the cassette.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
