# Extended thinking · 12 · Évora cork plank

The cork loft in Évora persists thinking on the assistant row. Inês
grades plank EVO-2026-1016-C2. Reloading the log still shows `thinking_signature` (and
`thinking_text` when the slug returns a summary).

**What it teaches**

- `acts_as_message` stores `thinking_text` and `thinking_signature`.
- Reload the cork log; the thinking columns are still there.
- `tokens.thinking` lives on the usage ledger, not those columns.

**Files**

| File | Role |
| --- | --- |
| [`cork.rb`](cork.rb) | Asks on a Rails cork log |
| [`cork_test.rb`](cork_test.rb) | Checks the columns after reload |
| [`cassettes/cork.yml`](cassettes/cork.yml) | The ask |

**Try it**

```sh
bundle exec ruby features/29-extended-thinking/12-evora-cork-plank/cork.rb
bundle exec ruby features/29-extended-thinking/12-evora-cork-plank/cork_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-5-nano`. Checked 16 October 2026.
