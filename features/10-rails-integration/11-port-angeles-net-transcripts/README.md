# Rails integration · 11 · Port Angeles net transcripts

The net loft at Port Angeles keeps a clerk-facing loft ticket and
a separate `llm_messages` transcript. RubyLLM only sees the latter.

**What it teaches**

- `acts_as_chat messages: :llm_messages` points the model at a different association.
- The loft ticket can hold a shorter clerk note. `llm_messages` keeps the system, user, and assistant rows.
- The two associations do not have to stay in lockstep.

**Files**

| File | Role |
| --- | --- |
| [`net_transcripts.rb`](net_transcripts.rb) | Asks on llm_messages and posts one loft ticket |
| [`net_transcripts_test.rb`](net_transcripts_test.rb) | Replays the cassette and checks both associations |
| [`cassettes/net_transcripts.yml`](cassettes/net_transcripts.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/11-port-angeles-net-transcripts/net_transcripts.rb
bundle exec ruby features/10-rails-integration/11-port-angeles-net-transcripts/net_transcripts_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after the
free OpenRouter slugs hit the daily cap on 14 October 2026. Re-record
it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/11-port-angeles-net-transcripts/net_transcripts.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Checked 14 October 2026.
