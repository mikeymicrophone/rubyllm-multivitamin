# Provider tools and citations · 06 · Bush Point code execution

The staff at Bush Point, on the west shore of Whidbey, interpolates the
kelp-ledge height at 10:46 before Alden leaves. `:code_execution` is
OpenAI's hosted `code_interpreter` with an auto container.

**What it teaches**

- `with_provider_tools(:code_execution)` sends
  `"type":"code_interpreter"` and `"container":{"type":"auto"}`.
- `:code_interpreter` is the same alias.
- `server_tool_calls` includes `code_interpreter_call`.
- `tokens.server_tool_use` stays `nil` on this recording even after the
  interpreter runs. Web search fills `web_search_requests`; this tool
  does not.

**Files**

| File | Role |
| --- | --- |
| [`staff_interp.rb`](staff_interp.rb) | Interpolates the Bush Point staff |
| [`staff_interp_test.rb`](staff_interp_test.rb) | Replays the cassette |
| [`cassettes/staff_interp.yml`](cassettes/staff_interp.yml) | Live OpenAI recording of `code_interpreter` |

**Try it**

```sh
bundle exec ruby features/18-provider-tools-and-citations/06-bush-point-code-execution/staff_interp_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/18-provider-tools-and-citations/06-bush-point-code-execution/staff_interp_test.rb
```

**Model**

`gpt-4.1-mini` with `provider: :openai`. Checked 15 October 2026.
