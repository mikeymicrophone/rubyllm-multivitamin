# Chat basics · 08 · Johannesburg clinic vitals round

Sister Nomsa at the Alexandra municipal clinic reads the morning clipboard back into the log. The round is a single ask. She decides it is finished with `stopped?`, not by hunting the word "stop" in the prose.

**What it teaches**

- `ask` returns the round as a `RubyLLM::Message`.
- `stopped?` is true when `finish_reason` is `:stop` and the message did not stop to call a tool.
- The clipboard facts (pulse, temperature, blood pressure, oxygen) are in `content`. The completion check does not depend on those words.

**Files**

| File | Role |
| --- | --- |
| [`vitals_round.rb`](vitals_round.rb) | Asks for the round and reads `stopped?` |
| [`vitals_round_test.rb`](vitals_round_test.rb) | Replays the cassette and checks `stopped?` and the clipboard |
| [`cassettes/vitals_round.yml`](cassettes/vitals_round.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/08-johannesburg-clinic-vitals/vitals_round.rb
bundle exec ruby features/01-chat-basics/08-johannesburg-clinic-vitals/vitals_round_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`. The round comes back 72 bpm, 36.8 C, 118/76, and 98 percent oxygen, and `stopped?` is true. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/08-johannesburg-clinic-vitals/vitals_round.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
