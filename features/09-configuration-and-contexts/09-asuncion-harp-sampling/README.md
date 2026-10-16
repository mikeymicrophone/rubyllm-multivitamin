# Configuration and contexts · 09 · Asunción harp sampling and params

The recording clerk at the Asunción folkloric harp desk posts the
31-cent detune twice. One chat sets `with_temperature` and
`with_provider_options(top_p:)`. The other leaves both unset so the
request omits them.

**What it teaches**

- `with_temperature` is a per-chat override, not a `RubyLLM.configure` option.
- `with_provider_options` is the RubyLLM 2.1.1 name for extra fields in the
  provider's request vocabulary. `Chat` does not respond to `with_params`.
- Until those are set, the wire has no `temperature` and no `top_p`.

**Files**

| File | Role |
| --- | --- |
| [`harp_sampling.rb`](harp_sampling.rb) | Asks the tuning board on a held chat and an unset chat |
| [`harp_sampling_test.rb`](harp_sampling_test.rb) | Replays the cassette and checks the request bodies |
| [`cassettes/harp_sampling.yml`](cassettes/harp_sampling.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/09-asuncion-harp-sampling/harp_sampling.rb
bundle exec ruby features/09-configuration-and-contexts/09-asuncion-harp-sampling/harp_sampling_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/09-asuncion-harp-sampling/harp_sampling.rb
```

**Model**

Recorded 16 October 2026 on `nvidia/nemotron-3-super-120b-a12b:free`
with `provider: :openrouter`. `CONFIGURATION_OPENROUTER_PAID=1` records
`openai/gpt-4.1-mini` on OpenRouter. A 512-token output cap is set so a
paid request fits this workspace's credits. Fallback:
`LIVE_PROVIDER=openai` records native `gpt-4.1-mini`.
