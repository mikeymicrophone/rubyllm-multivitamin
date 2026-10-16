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

Rendering is local. A follow-up `ask` that uses the rendered string records on OpenAI `gpt-4.1-mini`. Scenarios that only assert the rendered string, a missing file, or a partial need no HTTP cassette. Checked 16 October 2026.

## Examples (13 of 13 bottled)

01. [Tlemcen burnous wool](01-tlemcen-burnous-wool/) — available
02. [Bandung batik stamp](02-bandung-batik-stamp/) — available
03. [Kraków obwarzanek stall](03-krakow-obwarzanek-stall/) — available
04. [Mostar copper pot](04-mostar-copper-pot/) — available
05. [Taroudant tadelakt plaster](05-taroudant-tadelakt-plaster/) — available
06. [Ljubljana beehive panel](06-ljubljana-beehive-panel/) — available
07. [Yogyakarta wayang kulit](07-yogyakarta-wayang-kulit/) — available
08. [Mbarara ankole hide](08-mbarara-ankole-hide/) — available
09. [Valletta pastizzi dough](09-valletta-pastizzi-dough/) — available
10. [Gyumri khachkar carving](10-gyumri-khachkar-carving/) — available
11. [Harar bookbinding](11-harar-bookbinding/) — available
12. [Chichicastenango huipil](12-chichicastenango-huipil/) — available
13. [Kashgar atlas silk](13-kashgar-atlas-silk/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | `render_prompt` with locals, then `with_instructions` and `ask` |
| 02 | Missing file raises `PromptNotFoundError` before HTTP |
| 03 | Static prompt: no locals |
| 04 | Nested path `coppersmith/instructions` |
| 05 | `render "tone"` partial next to the prompt |
| 06 | `Prompt.roots <<` engine path; the host file wins |
| 07 | Agent with no prompt file starts without a system turn |
| 08 | `instructions { prompt("instructions") }` fails loudly when absent |
| 09 | Map a stall card to a known prompt name; do not interpolate |
| 10 | `ask` a rendered question template |
| 11 | Agent `instructions display_name:` lambda |
| 12 | Optional local through `local_assigns` |
| 13 | Capstone: nested path, partial, auto-loaded agent prompt, two asks |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
