# Configuration and contexts · 11 · Copán stela context embed

The epigrapher correcting Copán Stela 3 embeds the glyph-row notice
twice. The park context calls OpenRouter. The global desk calls OpenAI.
Each `Authorization` comes from the config that entry point used.

**What it teaches**

- `ctx.embed` uses the context's keys, base URL, and attribution.
- `RubyLLM.embed` uses `RubyLLM.config`, not the context that just ran.
- The cassette therefore holds two hosts and two filtered keys.

This example pins both providers. `LIVE_PROVIDER` does not retarget it.

**Files**

| File | Role |
| --- | --- |
| [`stela_embed.rb`](stela_embed.rb) | Embeds the stela notice through a context and through the global API |
| [`stela_embed_test.rb`](stela_embed_test.rb) | Replays the cassette and checks hosts and Authorization |
| [`cassettes/stela_embed.yml`](cassettes/stela_embed.yml) | OpenRouter embeddings, then OpenAI embeddings |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/11-copan-stela-embed/stela_embed.rb
bundle exec ruby features/09-configuration-and-contexts/11-copan-stela-embed/stela_embed_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... OPENAI_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/11-copan-stela-embed/stela_embed.rb
```

**Model**

Context: the free OpenRouter embedding slug when the daily cap allows,
or `openai/text-embedding-3-small` on OpenRouter when
`CONFIGURATION_OPENROUTER_PAID=1`. Global: `text-embedding-3-small` on
OpenAI.
