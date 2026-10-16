# Prompt rendering · 13 · Kashgar atlas silk

The atlas silk loft in Kashgar auto-loads the clerk's conventional
prompt, including a tone partial. Dilber warps lot KAS-2026-1016-A2,
then the follow-up still sees the standing order not to mix warp and weft.

**What it teaches**

- An Agent with no `instructions` macro auto-loads the conventional ERB.
- That file can nest a path and pull a partial.
- A follow-up ask still sees the rendered orders.

**Files**

| File | Role |
| --- | --- |
| [`atlas_silk.rb`](atlas_silk.rb) | Builds the clerk and asks twice |
| [`atlas_silk_test.rb`](atlas_silk_test.rb) | Checks the partial, the brief, and No |
| [`app/prompts/kashgar_atlas_silk/ikat_clerk/instructions.txt.erb`](app/prompts/kashgar_atlas_silk/ikat_clerk/instructions.txt.erb) | The auto-loaded card |
| [`app/prompts/kashgar_atlas_silk/ikat_clerk/_tone.txt.erb`](app/prompts/kashgar_atlas_silk/ikat_clerk/_tone.txt.erb) | The tone partial |
| [`cassettes/atlas_silk.yml`](cassettes/atlas_silk.yml) | Both asks |

**Try it**

```sh
bundle exec ruby features/28-prompt-rendering/13-kashgar-atlas-silk/atlas_silk.rb
bundle exec ruby features/28-prompt-rendering/13-kashgar-atlas-silk/atlas_silk_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-4.1-mini`. Rendering is local. Checked 16 October 2026.
