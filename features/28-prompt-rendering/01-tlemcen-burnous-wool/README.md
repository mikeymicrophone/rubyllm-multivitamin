# Prompt rendering · 01 · Tlemcen burnous wool

The burnous clerk in Tlemcen renders standing orders with Yasmina's
name and lot TLM-2026-1016-B4, then asks when she cards.

**What it teaches**

- `RubyLLM.render_prompt` fills ERB locals and returns a string.
- That string is a normal `with_instructions` argument.
- Rendering is local; the cassette is the ask that uses it.

**Files**

| File | Role |
| --- | --- |
| [`burnous.rb`](burnous.rb) | Renders the orders and asks |
| [`burnous_test.rb`](burnous_test.rb) | Checks the locals and the brief |
| [`app/prompts/burnous/instructions.txt.erb`](app/prompts/burnous/instructions.txt.erb) | The standing orders |
| [`cassettes/burnous.yml`](cassettes/burnous.yml) | The ask |

**Try it**

```sh
bundle exec ruby features/28-prompt-rendering/01-tlemcen-burnous-wool/burnous.rb
bundle exec ruby features/28-prompt-rendering/01-tlemcen-burnous-wool/burnous_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-4.1-mini`. Rendering is local. Checked 16 October 2026.
