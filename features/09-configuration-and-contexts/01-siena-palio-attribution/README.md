# Configuration and contexts · 01 · Siena Palio attribution headers

The prova clerk at Contrada della Torre attributes the OpenRouter call
to the Comune page. A chat that tries to replace `HTTP-Referer` with a
Siena tour-desk URL still sends the Comune URL, and the overnight
drappellone header rides along.

**What it teaches**

- `openrouter_app_url` is sent as `HTTP-Referer`.
- `openrouter_app_name` is sent as `X-OpenRouter-Title`.
- `with_headers` stores extra headers on the chat. Provider headers win on
  overlapping names, so the attempted tour-desk referer never leaves.
- A header the provider does not set, `X-Siena-Watch`, is on the wire.

**Files**

| File | Role |
| --- | --- |
| [`attribution.rb`](attribution.rb) | Configures contrada attribution and asks the prova question |
| [`attribution_test.rb`](attribution_test.rb) | Replays the cassette and checks the headers |
| [`cassettes/attribution.yml`](cassettes/attribution.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/01-siena-palio-attribution/attribution.rb
bundle exec ruby features/09-configuration-and-contexts/01-siena-palio-attribution/attribution_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/01-siena-palio-attribution/attribution.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any
`sk-or-v1-` token before the file is written.

**Model**

Recorded on the free OpenRouter chat slug when the daily cap allows.
`CONFIGURATION_OPENROUTER_PAID=1` records `openai/gpt-4.1-mini` on
OpenRouter so `HTTP-Referer` and `X-OpenRouter-Title` stay on the wire.
A 512-token output cap is set so a paid request fits this workspace's
credits. Fallback: `LIVE_PROVIDER=openai` records native `gpt-4.1-mini`.
