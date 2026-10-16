# Prompt rendering · 06 · Ljubljana beehive panel

The beehive loft in Ljubljana ships a kranjska panel prompt from an
engine. The host file at the same path wins. An engine-only card is
visible only after `Prompt.roots <<`.

**What it teaches**

- `Prompt.roots` is the search path. The scenario `app/prompts` is first.
- An engine directory appended with `<<` is searched next.
- A host file at the same relative path overrides the engine.

**Files**

| File | Role |
| --- | --- |
| [`beehive_panel.rb`](beehive_panel.rb) | Appends the engine root and renders both cards |
| [`beehive_panel_test.rb`](beehive_panel_test.rb) | Checks the host win and the gap |
| [`app/prompts/panel/instructions.txt.erb`](app/prompts/panel/instructions.txt.erb) | The host override |
| [`engine/app/prompts/panel/instructions.txt.erb`](engine/app/prompts/panel/instructions.txt.erb) | The engine copy that loses |
| [`engine/app/prompts/engine_only/card.txt.erb`](engine/app/prompts/engine_only/card.txt.erb) | The engine-only card |

**Try it**

```sh
bundle exec ruby features/28-prompt-rendering/06-ljubljana-beehive-panel/beehive_panel.rb
bundle exec ruby features/28-prompt-rendering/06-ljubljana-beehive-panel/beehive_panel_test.rb
```

No API key is required. Checked 16 October 2026.
