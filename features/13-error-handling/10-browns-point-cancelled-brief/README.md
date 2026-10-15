# Error handling · 10 · Browns Point cancelled brief

The fog clerk at Browns Point, on Commencement Bay, starts a spoken
visibility brief and stops it after two spoken pieces. The rest of the
card stays in the recorded stream. The assistant turn is not appended.

**What it teaches**

- `chat.cancel` does not raise inside the block. The next chunk
  checkpoint raises `RubyLLM::CancelledError`.
- `CancelledError` inherits `StandardError`, not `RubyLLM::Error`.
- After the halt, `chat.messages` is still `[:system, :user]`.
- The cassette keeps the full SSE body. Replay stops at the same prefix.

**Files**

| File | Role |
| --- | --- |
| [`cancelled_brief.rb`](cancelled_brief.rb) | Streams the card and cancels after two pieces |
| [`cancelled_brief_test.rb`](cancelled_brief_test.rb) | Checks the error, the roles, and the leftover deltas |
| [`cassettes/cancelled_brief.yml`](cassettes/cancelled_brief.yml) | The streamed Responses call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/10-browns-point-cancelled-brief/cancelled_brief.rb
bundle exec ruby features/13-error-handling/10-browns-point-cancelled-brief/cancelled_brief_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/13-error-handling/10-browns-point-cancelled-brief/cancelled_brief.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Checked 15 October 2026.
