# Extended thinking · 10 · Gondar parchment folio

The parchment desk in Gondar files token counts on a summarized
thinking turn. Yonas rules folio GON-2026-1016-P5. `tokens.thinking`
is already inside `tokens.output`. `cost.thinking` is nil on this slug.

**What it teaches**

- `tokens.thinking` is an Integer on `gpt-5-nano`.
- `tokens.output` already includes that work; do not add them.
- `cost.thinking` is nil when the registry has no separate reasoning price.

**Files**

| File | Role |
| --- | --- |
| [`parchment.rb`](parchment.rb) | Asks and reads tokens and cost |
| [`parchment_test.rb`](parchment_test.rb) | Checks the integer split and the nil thinking cost |
| [`cassettes/parchment.yml`](cassettes/parchment.yml) | The ask |

**Try it**

```sh
bundle exec ruby features/29-extended-thinking/10-gondar-parchment-folio/parchment.rb
bundle exec ruby features/29-extended-thinking/10-gondar-parchment-folio/parchment_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-5-nano`. Checked 16 October 2026.
