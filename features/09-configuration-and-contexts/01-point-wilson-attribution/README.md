# Configuration and contexts · 01 · Point Wilson attribution headers

The tide clerk at Point Wilson Light Station attributes the OpenRouter call
to the station page. A chat that tries to replace `HTTP-Referer` with the
Port of Tacoma URL still sends the station URL, and the overnight watch
header rides along.

**What it teaches**

- `openrouter_app_url` is sent as `HTTP-Referer`.
- `openrouter_app_name` is sent as `X-OpenRouter-Title`.
- `with_headers` stores extra headers on the chat. Provider headers win on
  overlapping names, so the attempted Port of Tacoma referer never leaves.
- A header the provider does not set, `X-Point-Wilson-Watch`, is on the wire.

**Files**

| File | Role |
| --- | --- |
| [`attribution.rb`](attribution.rb) | Configures station attribution and asks the kelp-ledge question |
| [`attribution_test.rb`](attribution_test.rb) | Replays the cassette and checks the headers |
| [`cassettes/attribution.yml`](cassettes/attribution.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/01-point-wilson-attribution/attribution.rb
bundle exec ruby features/09-configuration-and-contexts/01-point-wilson-attribution/attribution_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/01-point-wilson-attribution/attribution.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any
`sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
