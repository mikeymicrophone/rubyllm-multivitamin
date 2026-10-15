# Agents · 03 · Cape Disappointment blast card

The foghorn clerk at Cape Disappointment fills a blast card from the posted
horn pattern. The schema lives on the agent class as an inline DSL block,
not a separate `Schematist::Schema` subclass.

**What it teaches**

- `schema do ... end` on an Agent is the Schematist DSL.
- `ask` still returns a `RubyLLM::Message`. `parsed` is the Hash.
- `content` stays the JSON text. `JSON.parse(content)` equals `parsed`.
- Integer fields come back as numbers.

**Files**

| File | Role |
| --- | --- |
| [`blast_card.rb`](blast_card.rb) | Declares the horn-clerk agent and asks for the card |
| [`blast_card_test.rb`](blast_card_test.rb) | Checks the parsed blast, gap, and compressor fields |
| [`cassettes/blast_card.yml`](cassettes/blast_card.yml) | The structured-output round-trip |

**Try it**

```sh
bundle exec ruby features/14-agents/03-cape-disappointment-blast-card/blast_card.rb
bundle exec ruby features/14-agents/03-cape-disappointment-blast-card/blast_card_test.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. The model lists `structured_outputs`. Fallback:
OpenRouter `nvidia/nemotron-3-super-120b-a12b:free` when that slug does.
Checked 15 October 2026.
