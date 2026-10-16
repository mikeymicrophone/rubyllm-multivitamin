# Extended thinking · 04 · Aizawl puan cloth

The puan loft in Aizawl asks for a summarized thinking display. Lalrin
weaves puan AIZ-2026-1016-P4. The Responses body includes
`reasoning.summary auto`, and both `thinking.text` and `signature` are set.

**What it teaches**

- `display: :summarized` asks the Responses API for a reasoning summary.
- `thinking.text` is that summary.
- `thinking.signature` is the encrypted block.

**Files**

| File | Role |
| --- | --- |
| [`puan.rb`](puan.rb) | Pins summarized display and asks |
| [`puan_test.rb`](puan_test.rb) | Checks text, signature, and the wire |
| [`cassettes/puan.yml`](cassettes/puan.yml) | The ask |

**Try it**

```sh
bundle exec ruby features/29-extended-thinking/04-aizawl-puan-cloth/puan.rb
bundle exec ruby features/29-extended-thinking/04-aizawl-puan-cloth/puan_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-5-nano`. Checked 16 October 2026.
