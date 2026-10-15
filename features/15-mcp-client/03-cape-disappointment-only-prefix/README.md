# MCP client · 03 · Cape Disappointment only/except/prefix

The horn clerk at Cape Disappointment must see the blast card and the tide board, never the control that silences the horn. The names are prefixed so a second desk could share the chat.

**What it teaches**

- `only` keeps the tools the model may see.
- `except :silence_horn` hides that control even though `only` listed it.
- `prefix :cape` rewrites `posted_horn_card` to `cape_posted_horn_card`.

**Files**

| File | Role |
| --- | --- |
| [`horn_prefix.rb`](horn_prefix.rb) | The Cape Horn desk class and the blast question |
| [`horn_prefix_test.rb`](horn_prefix_test.rb) | Replays the cassette |
| [`desk.json`](desk.json) | Stdio profile for the horn, tide, and silence tools |
| [`cassettes/horn_prefix.yml`](cassettes/horn_prefix.yml) | Live OpenAI recording |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/15-mcp-client/03-cape-disappointment-only-prefix/horn_prefix_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/15-mcp-client/03-cape-disappointment-only-prefix/horn_prefix_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
