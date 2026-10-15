# MCP client · 07 · Anacortes prompt through ask

The retort clerk at the Anacortes cannery fills the `retort_cook_brief` prompt with basket 3. `ask` adds every turn the server wrote, then the model answers from the cook card.

**What it teaches**

- `desk.prompt(:retort_cook_brief, basket: "3")` fills the arguments.
- `ask` adds the prompt's user and assistant turns.
- Prompts are chosen by people, like a slash command on the cook desk.

**Files**

| File | Role |
| --- | --- |
| [`cook_prompt.rb`](cook_prompt.rb) | Fills the retort prompt and asks with it |
| [`cook_prompt_test.rb`](cook_prompt_test.rb) | Replays the cassette |
| [`desk.json`](desk.json) | Stdio profile with the cook prompt |
| [`cassettes/cook_prompt.yml`](cassettes/cook_prompt.yml) | Live OpenAI recording |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/15-mcp-client/07-anacortes-prompt-ask/cook_prompt_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/15-mcp-client/07-anacortes-prompt-ask/cook_prompt_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
