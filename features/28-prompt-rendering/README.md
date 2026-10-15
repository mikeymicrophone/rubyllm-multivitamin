# Prompt rendering

`RubyLLM.render_prompt("support/instructions", product_name: "...")` renders `app/prompts/support/instructions.txt.erb`. Missing files raise `PromptNotFoundError`. Partials are `_tone.txt.erb` via `render "tone"`. `RubyLLM::Prompt.roots` is the search path. Agents auto-load `app/prompts/<agent>/instructions.txt.erb`. `instructions { prompt("instructions") }` fails loudly when the file is absent. Locals are ERB, not a provider call; many scenarios here need no cassette.

Official reference: [Prompt Rendering](https://rubyllm.com/prompt-rendering/).

## RubyLLM 2.1.1 entry points

- `RubyLLM.render_prompt("support/instructions", name: "Alden")`
- `app/prompts/**/*.txt.erb`
- `render "tone"` partials and `local_assigns`
- `RubyLLM::Prompt.roots`
- `RubyLLM::PromptNotFoundError`
- agent `instructions { prompt("instructions") }`

## Providers that can record it

Rendering is local. A follow-up `ask` that uses the rendered string records on the chat provider: OpenRouter `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`, or OpenAI `gpt-4.1-mini`. Scenarios that only assert the rendered string, a missing file, or a partial need no HTTP cassette.

## Examples (0 of 13 bottled)

01. Elliott Bay station instructions — planned
02. Shilshole missing prompt — planned
03. Golden Gardens welcome locals — planned
04. Meadow Point nested path — planned
05. Carkeek tone partial — planned
06. Richmond Beach engine roots — planned
07. Edmonds empty agent template — planned
08. Possession Sound prompt("instructions") — planned
09. Gedney untrusted name — planned
10. Hat Island chat.with_instructions render — planned
11. Priest Point display_name lambda — planned
12. Tulalip local_assigns optional — planned
13. Camano prompt desk capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
