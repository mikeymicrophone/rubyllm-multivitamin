# Configuration and contexts · 09 · Port Townsend sampling and params

The slip clerk at the Port Townsend ferry terminal posts the 31-knot gust
twice. One chat sets `with_temperature` and `with_provider_options(top_p:)`.
The other leaves both unset so the request omits them.

**What it teaches**

- `with_temperature` is a per-chat override, not a `RubyLLM.configure` option.
- `with_provider_options` is the RubyLLM 2.1.1 name for extra fields in the
  provider's request vocabulary. `Chat` does not respond to `with_params`.
- Until those are set, the wire has no `temperature` and no `top_p`.

**Files**

| File | Role |
| --- | --- |
| [`slip_sampling.rb`](slip_sampling.rb) | Asks the wind board on a held chat and an unset chat |
| [`slip_sampling_test.rb`](slip_sampling_test.rb) | Replays the cassette and checks the request bodies |
| [`cassettes/slip_sampling.yml`](cassettes/slip_sampling.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/09-port-townsend-sampling/slip_sampling.rb
bundle exec ruby features/09-configuration-and-contexts/09-port-townsend-sampling/slip_sampling_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/09-port-townsend-sampling/slip_sampling.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
