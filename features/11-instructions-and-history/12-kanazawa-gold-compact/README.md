# Instructions and history · 12 · Kanazawa gold-leaf log compacted

The loft clerk in Higashi Chaya logs three overnight notices — the DH
move, the humidity over the posted band, and the unchanged burnishing
bench — asks for a two-sentence handover, then keeps four turns before
the relief asks whether DH is still on the printed mark.

**What it teaches**

- A long overnight log can be summarized on the same chat.
- `chat.messages =` keeps four turns: the system prompt, the first DH
  notice, the summary question, and the summary.
- The next request drops the middle notices. Humidity and the
  unchanged burnishing bench are gone from that body.

**Files**

| File | Role |
| --- | --- |
| [`leaf_compact.rb`](leaf_compact.rb) | Logs three notices, summarizes, compacts, asks again |
| [`leaf_compact_test.rb`](leaf_compact_test.rb) | Replays the cassette and checks the kept turns |
| [`cassettes/leaf_compact.yml`](cassettes/leaf_compact.yml) | Live recording of the overnight log |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/12-kanazawa-gold-compact/leaf_compact.rb
bundle exec ruby features/11-instructions-and-history/12-kanazawa-gold-compact/leaf_compact_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/12-kanazawa-gold-compact/leaf_compact.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` inverted a Yes/No standing
order on 16 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
