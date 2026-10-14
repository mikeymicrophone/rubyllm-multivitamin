# Instructions and history · 12 · Juan de Fuca overnight log compacted

The mate on NOAA chart 18465 logs three overnight notices — the DH move,
Race Rocks visibility, and the New Dungeness sector — asks for a
two-sentence handover, then keeps four turns before the relief asks
whether DH is still on the printed symbol.

**What it teaches**

- A long overnight log can be summarized on the same chat.
- `chat.messages =` keeps four turns: the system prompt, the first DH
  notice, the summary question, and the summary.
- The next request drops the middle notices. Race Rocks and the
  unchanged New Dungeness sector are gone from that body.

**Files**

| File | Role |
| --- | --- |
| [`log_compact.rb`](log_compact.rb) | Logs three notices, summarizes, compacts, asks again |
| [`log_compact_test.rb`](log_compact_test.rb) | Replays the cassette and checks the kept turns |
| [`cassettes/log_compact.yml`](cassettes/log_compact.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/12-juan-de-fuca-log-compact/log_compact.rb
bundle exec ruby features/11-instructions-and-history/12-juan-de-fuca-log-compact/log_compact_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/12-juan-de-fuca-log-compact/log_compact.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded:
free-models-per-day` on 14 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
