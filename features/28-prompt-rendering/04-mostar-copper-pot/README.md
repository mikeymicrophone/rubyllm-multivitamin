# Prompt rendering · 04 · Mostar copper pot

The coppersmith on Kujundžiluk renders a nested path, then the same
file with its `.txt.erb` suffix. Emir hammers pot MST-2026-1016-C5.

**What it teaches**

- Nested prompt names resolve under `app/prompts`.
- The full filename with `.txt.erb` is accepted too.
- Both paths render the same card.

**Files**

| File | Role |
| --- | --- |
| [`copper_pot.rb`](copper_pot.rb) | Renders both names and asks |
| [`copper_pot_test.rb`](copper_pot_test.rb) | Checks the two strings match |
| [`app/prompts/coppersmith/instructions.txt.erb`](app/prompts/coppersmith/instructions.txt.erb) | The nested card |
| [`cassettes/copper_pot.yml`](cassettes/copper_pot.yml) | The ask |

**Try it**

```sh
bundle exec ruby features/28-prompt-rendering/04-mostar-copper-pot/copper_pot.rb
bundle exec ruby features/28-prompt-rendering/04-mostar-copper-pot/copper_pot_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-4.1-mini`. Rendering is local. Checked 16 October 2026.
