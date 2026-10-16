# Configuration and contexts · 08 · Limoges enamel OpenRouter base URL

The enamel studio on rue du Consulat in Limoges points one context at
OpenRouter's public v1 base, keeps `http_proxy` unset, and stores the
model registry file beside the firing board instead of in the user cache.

**What it teaches**

- `openrouter_api_base` on a context is the Faraday base the cassette
  records. The global reader stays `nil`, which still means that same
  public URL inside the OpenRouter provider.
- `http_proxy` left unset is `nil` on the context and on `RubyLLM.config`.
- `model_registry_file` can point at a path inside the scenario folder.

**Files**

| File | Role |
| --- | --- |
| [`enamel_base.rb`](enamel_base.rb) | Sets the base URL and registry path, then asks the soak time |
| [`enamel_base_test.rb`](enamel_base_test.rb) | Replays the cassette and checks the URI, proxy, and path |
| [`cassettes/enamel_base.yml`](cassettes/enamel_base.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/08-limoges-enamel-base/enamel_base.rb
bundle exec ruby features/09-configuration-and-contexts/08-limoges-enamel-base/enamel_base_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/08-limoges-enamel-base/enamel_base.rb
```

**Model**

Recorded 16 October 2026 on `nvidia/nemotron-3-super-120b-a12b:free`
with `provider: :openrouter`. `CONFIGURATION_OPENROUTER_PAID=1` records
`openai/gpt-4.1-mini` on OpenRouter. A 512-token output cap is set so a
paid request fits this workspace's credits. Fallback:
`LIVE_PROVIDER=openai` records native `gpt-4.1-mini`.
