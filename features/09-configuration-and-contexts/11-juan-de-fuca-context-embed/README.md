# Configuration and contexts · 11 · Juan de Fuca context embed

The mate correcting NOAA chart 18465 embeds the Dungeness Spit bell-buoy
notice twice. The Strait context calls OpenRouter. The global desk calls
OpenAI. Each `Authorization` comes from the config that entry point used.

**What it teaches**

- `ctx.embed` uses the context's keys, base URL, and attribution.
- `RubyLLM.embed` uses `RubyLLM.config`, not the context that just ran.
- The cassette therefore holds two hosts and two filtered keys.

This example pins both providers. `LIVE_PROVIDER` does not retarget it.

**Files**

| File | Role |
| --- | --- |
| [`chart_embed.rb`](chart_embed.rb) | Embeds the chart notice through a context and through the global API |
| [`chart_embed_test.rb`](chart_embed_test.rb) | Replays the cassette and checks hosts and Authorization |
| [`cassettes/chart_embed.yml`](cassettes/chart_embed.yml) | OpenRouter embeddings, then OpenAI embeddings |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/11-juan-de-fuca-context-embed/chart_embed.rb
bundle exec ruby features/09-configuration-and-contexts/11-juan-de-fuca-context-embed/chart_embed_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... OPENAI_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/11-juan-de-fuca-context-embed/chart_embed.rb
```

**Model**

Context: `nvidia/nemotron-3-embed-1b:free` on OpenRouter. Global:
`text-embedding-3-small` on OpenAI. Fallback if the free embedding slug is
capped: record the context call on OpenAI as well and update the test.
Checked 14 October 2026.
