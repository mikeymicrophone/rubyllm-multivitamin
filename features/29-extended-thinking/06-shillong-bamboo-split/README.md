# Extended thinking · 06 · Shillong bamboo split

The bamboo yard in Shillong streams a summarized thinking turn. Bina
splits cane SHL-2026-1016-B8. Thinking deltas join to
`message.thinking.text`; spoken pieces join to the brief.

**What it teaches**

- A streamed ask with `display: :summarized` yields `chunk.thinking`.
- Joining those deltas equals `message.thinking.text`.
- Spoken content still arrives on `chunk.content`.

**Files**

| File | Role |
| --- | --- |
| [`bamboo.rb`](bamboo.rb) | Streams thinking and speech |
| [`bamboo_test.rb`](bamboo_test.rb) | Checks the joins |
| [`cassettes/bamboo.yml`](cassettes/bamboo.yml) | The SSE ask |

**Try it**

```sh
bundle exec ruby features/29-extended-thinking/06-shillong-bamboo-split/bamboo.rb
bundle exec ruby features/29-extended-thinking/06-shillong-bamboo-split/bamboo_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-5-nano`. Checked 16 October 2026.
