# Chat basics · 06 · Tallinn readiness probe check

SRE Kadri checks the readiness probe configured for the SEPA settlement pod at Lõhmus Clearing in Tallinn. The same question goes to two cheap OpenAI models. A follow-up about the spare 6 second timeout stays on the first chat after `with_model` switches it.

**What it teaches**

- Each chat is opened with `provider: :openai`. One chat uses `gpt-4.1-mini`. A fresh chat uses `gpt-4o-mini` and is asked the same probe question.
- `message.model` is the id the provider returned for that reply, so the two answers can be told apart.
- `with_model` on the first chat switches the spare-timeout question to `gpt-4o-mini` without dropping the 9 second probe turn.

**Files**

| File | Role |
| --- | --- |
| [`probe_check.rb`](probe_check.rb) | Asks two models, then switches model for the spare timeout |
| [`probe_check_test.rb`](probe_check_test.rb) | Replays the cassette and checks both model ids and the transcript |
| [`cassettes/probe_check.yml`](cassettes/probe_check.yml) | The three Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/06-tallinn-readiness-probe/probe_check.rb
bundle exec ruby features/01-chat-basics/06-tallinn-readiness-probe/probe_check_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording. The `gpt-4.1-mini` reply and the fresh `gpt-4o-mini` reply both see the 9 second timeout. The spare-timeout question is `gpt-4o-mini`, on the chat that already holds the first turn. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/01-chat-basics/06-tallinn-readiness-probe/probe_check.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` and `gpt-4o-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter `:free` slugs hit `free-models-per-day` on 15 October 2026.
