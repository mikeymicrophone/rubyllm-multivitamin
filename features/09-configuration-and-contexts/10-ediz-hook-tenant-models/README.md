# Configuration and contexts · 10 · Ediz Hook and Port Angeles default models

The buoy tender off Ediz Hook and the loft clerk at Port Angeles each get
a context with its own `default_model`. Neither `chat` call names a slug.
The cassette bodies still carry two different ids.

**What it teaches**

- `default_model` on a context is the id `ctx.chat` uses when `model:` is
  omitted.
- Two tenants can pin two different free slugs.
- `RubyLLM.config.default_model` stays the library default (`gpt-5.6`)
  after both chats.

**Files**

| File | Role |
| --- | --- |
| [`tenant_models.rb`](tenant_models.rb) | Sets two tenant defaults and asks one ledger and one mending ticket |
| [`tenant_models_test.rb`](tenant_models_test.rb) | Replays the cassette and checks both slugs |
| [`cassettes/tenant_models.yml`](cassettes/tenant_models.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/10-ediz-hook-tenant-models/tenant_models.rb
bundle exec ruby features/09-configuration-and-contexts/10-ediz-hook-tenant-models/tenant_models_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/10-ediz-hook-tenant-models/tenant_models.rb
```

**Model**

Ediz Hook: `nvidia/nemotron-3-super-120b-a12b:free`. Port Angeles loft:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
