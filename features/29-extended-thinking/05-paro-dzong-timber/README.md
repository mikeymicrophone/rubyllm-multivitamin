# Extended thinking · 05 · Paro dzong timber

The timber yard below Paro Dzong pins `display: :omitted`. Tashi marks
beam PAR-2026-1016-Z6. The model still thinks; the summary stays off
the wire and `thinking.text` is nil.

**What it teaches**

- `display: :omitted` keeps thinking on without a summary.
- `thinking.text` is nil. The signature may still arrive.
- The wire has effort and no `summary: auto`.

**Files**

| File | Role |
| --- | --- |
| [`dzong.rb`](dzong.rb) | Pins omitted display and asks |
| [`dzong_test.rb`](dzong_test.rb) | Checks the nil text and the wire |
| [`cassettes/dzong.yml`](cassettes/dzong.yml) | The ask |

**Try it**

```sh
bundle exec ruby features/29-extended-thinking/05-paro-dzong-timber/dzong.rb
bundle exec ruby features/29-extended-thinking/05-paro-dzong-timber/dzong_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-5-nano`. Checked 16 October 2026.
