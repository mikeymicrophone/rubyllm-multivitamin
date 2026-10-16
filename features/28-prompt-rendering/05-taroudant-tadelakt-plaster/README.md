# Prompt rendering · 05 · Taroudant tadelakt plaster

The tadelakt yard in Taroudant shares a tone partial with the morning
cistern card. Fatima coats lot TAR-2026-1016-T3.

**What it teaches**

- `render "tone"` looks next to the current prompt for `_tone.txt.erb`.
- Partials receive only the locals you pass.
- This run does not write a cassette.

**Files**

| File | Role |
| --- | --- |
| [`tadelakt.rb`](tadelakt.rb) | Renders the card and the partial |
| [`tadelakt_test.rb`](tadelakt_test.rb) | Checks the partial sits inside the card |
| [`app/prompts/tadelakt/instructions.txt.erb`](app/prompts/tadelakt/instructions.txt.erb) | The cistern card |
| [`app/prompts/tadelakt/_tone.txt.erb`](app/prompts/tadelakt/_tone.txt.erb) | The tone partial |

**Try it**

```sh
bundle exec ruby features/28-prompt-rendering/05-taroudant-tadelakt-plaster/tadelakt.rb
bundle exec ruby features/28-prompt-rendering/05-taroudant-tadelakt-plaster/tadelakt_test.rb
```

No API key is required. Checked 16 October 2026.
