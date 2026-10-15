# Chat basics · 06 · Tallinn readiness probe check

SRE Kadri checks the readiness probe configured for the SEPA settlement pod at Lõhmus Clearing in Tallinn. The same question goes to two free models. A follow-up about the spare 6 second timeout stays on the first chat after `with_model` switches it.

**What it teaches**

- Each chat is opened with `provider: :openrouter` and `assume_model_exists: true`. The free slugs are newer than RubyLLM's bundled registry, and the flag requires a provider.
- One chat uses `nvidia/nemotron-3-super-120b-a12b:free`. A fresh chat uses `liquid/lfm-2.5-2.6b:free` and is asked the same probe question.
- `message.model` is the id the provider returned for that reply, so the two answers can be told apart.
- `with_model` on the first chat switches the spare-timeout question to the liquid slug without dropping the 9 second probe turn.

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

The cassette is a live recording. The nemotron reply and the fresh liquid reply both see the 9 second timeout. The spare-timeout question is the liquid model, on the chat that already holds the first turn. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/06-tallinn-readiness-probe/probe_check.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` and `liquid/lfm-2.5-2.6b:free` on OpenRouter. Checked 14 October 2026.
