# Prompt rendering · 03 · Kraków obwarzanek stall

The obwarzanek stall in Kraków keeps a static prompt with no locals.
Zofia bags stall KRK-2026-1016-O2 at 06:40.

**What it teaches**

- A prompt file does not need locals.
- `render_prompt("obwarzanek")` resolves `obwarzanek.txt.erb`.
- The rendered string is still a `with_instructions` argument.

**Files**

| File | Role |
| --- | --- |
| [`obwarzanek.rb`](obwarzanek.rb) | Renders the static card and asks |
| [`obwarzanek_test.rb`](obwarzanek_test.rb) | Checks the string and the brief |
| [`app/prompts/obwarzanek.txt.erb`](app/prompts/obwarzanek.txt.erb) | The stall orders |
| [`cassettes/obwarzanek.yml`](cassettes/obwarzanek.yml) | The ask |

**Try it**

```sh
bundle exec ruby features/28-prompt-rendering/03-krakow-obwarzanek-stall/obwarzanek.rb
bundle exec ruby features/28-prompt-rendering/03-krakow-obwarzanek-stall/obwarzanek_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-4.1-mini`. Rendering is local. Checked 16 October 2026.
