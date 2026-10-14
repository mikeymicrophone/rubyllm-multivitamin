# Configuration and contexts · 08 · Bremerton OpenRouter base URL

The yard clerk at Bremerton Marina points one context at OpenRouter's
public v1 base, keeps `http_proxy` unset, and stores the model registry
file beside the gate log instead of in the user cache.

**What it teaches**

- `openrouter_api_base` on a context is the Faraday base the cassette
  records. The global reader stays `nil`, which still means that same
  public URL inside the OpenRouter provider.
- `http_proxy` left unset is `nil` on the context and on `RubyLLM.config`.
- `model_registry_file` can point at a path inside the scenario folder.

**Files**

| File | Role |
| --- | --- |
| [`dry_dock_base.rb`](dry_dock_base.rb) | Sets the base URL and registry path, then asks the flood time |
| [`dry_dock_base_test.rb`](dry_dock_base_test.rb) | Replays the cassette and checks the URI, proxy, and path |
| [`cassettes/dry_dock_base.yml`](cassettes/dry_dock_base.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/08-bremerton-openrouter-base/dry_dock_base.rb
bundle exec ruby features/09-configuration-and-contexts/08-bremerton-openrouter-base/dry_dock_base_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/08-bremerton-openrouter-base/dry_dock_base.rb
```

**Model**

Recorded on `openai/gpt-4.1-mini` with `provider: :openrouter` because the
`:free` chat slugs were past the daily cap. A 512-token output cap is set
so the request fits this workspace's OpenRouter credits. Fallback:
`LIVE_PROVIDER=openai` records native `gpt-4.1-mini`. Checked 14 October 2026.
