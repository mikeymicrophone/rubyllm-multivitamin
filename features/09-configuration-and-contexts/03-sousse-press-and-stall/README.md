# Configuration and contexts · 03 · Sousse olive press and medina stall

Huilerie Riadh and the Souk el-Caïd stall each get a `RubyLLM.context`.
Each chats once under its own OpenRouter title. The global catalog
attribution is still in place after both.

**What it teaches**

- `RubyLLM.context` dups `RubyLLM.config` and yields the copy.
- `ctx.chat` uses that copy. The two tenants send different
  `X-OpenRouter-Title` values.
- Mutating the yielded config does not change `RubyLLM.config`.

**Files**

| File | Role |
| --- | --- |
| [`tenants.rb`](tenants.rb) | Builds two contexts and asks one press question and one receiving card |
| [`tenants_test.rb`](tenants_test.rb) | Replays the cassette and checks titles on the wire |
| [`cassettes/tenants.yml`](cassettes/tenants.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/03-sousse-press-and-stall/tenants.rb
bundle exec ruby features/09-configuration-and-contexts/03-sousse-press-and-stall/tenants_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/03-sousse-press-and-stall/tenants.rb
```

**Model**

Recorded 16 October 2026 on `nvidia/nemotron-3-super-120b-a12b:free`
with `provider: :openrouter`. `CONFIGURATION_OPENROUTER_PAID=1` records
`openai/gpt-4.1-mini` on OpenRouter. A 512-token output cap is set so a
paid request fits this workspace's credits. Fallback:
`LIVE_PROVIDER=openai` records native `gpt-4.1-mini`.
