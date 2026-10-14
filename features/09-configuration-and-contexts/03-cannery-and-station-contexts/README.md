# Configuration and contexts · 03 · Cannery tenant and light station

Point Wilson Light Station and the Anacortes cannery each get a
`RubyLLM.context`. Each chats once under its own OpenRouter title. The
global catalog attribution is still in place after both.

**What it teaches**

- `RubyLLM.context` dups `RubyLLM.config` and yields the copy.
- `ctx.chat` uses that copy. The two tenants send different
  `X-OpenRouter-Title` values.
- Mutating the yielded config does not change `RubyLLM.config`.

**Files**

| File | Role |
| --- | --- |
| [`tenants.rb`](tenants.rb) | Builds two contexts and asks one station question and one cook card |
| [`tenants_test.rb`](tenants_test.rb) | Replays the cassette and checks titles on the wire |
| [`cassettes/tenants.yml`](cassettes/tenants.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/03-cannery-and-station-contexts/tenants.rb
bundle exec ruby features/09-configuration-and-contexts/03-cannery-and-station-contexts/tenants_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/03-cannery-and-station-contexts/tenants.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
