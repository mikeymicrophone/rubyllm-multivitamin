# MCP client · 10 · Port Townsend input-request pause

The slip clerk at Port Townsend asks which slip the Chetzemoka should take. The desk stops the tool call with a form. No callback answers, so the chat pauses. `answer(slip: "A")` then `complete` finishes the call.

**What it teaches**

- A server can return `input_required` in the middle of a tool call.
- `chat.awaiting_input?` is true until the watch answers.
- `answer` then `complete` sends the slip and finishes the call.

**Files**

| File | Role |
| --- | --- |
| [`slip_pause.rb`](slip_pause.rb) | Calls the slip tool, answers A, then completes |
| [`slip_pause_test.rb`](slip_pause_test.rb) | Replays the cassette |
| [`desk.json`](desk.json) | Stdio profile with the slip elicitation |
| [`cassettes/slip_pause.yml`](cassettes/slip_pause.yml) | Live OpenAI recording |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/15-mcp-client/10-port-townsend-input/slip_pause_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/15-mcp-client/10-port-townsend-input/slip_pause_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
