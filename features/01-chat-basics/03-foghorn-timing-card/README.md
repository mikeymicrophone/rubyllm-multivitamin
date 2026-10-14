# Chat basics · 03 · Foghorn timing card at Cape Disappointment

The horn tender at Cape Disappointment copies the posted timing card onto the watch slate. A low temperature and a three-line instruction keep the diaphone's blast and silence from growing a paragraph.

**What it teaches**

- `with_temperature(0.0)` sets sampling on this chat before the ask.
- `with_instructions` tells the tender the three lines the slate is allowed to carry.
- The reply is still a `RubyLLM::Message`. Short does not mean missing: `content` holds the card, and `finish_reason` still says why it stopped.

**Files**

| File | Role |
| --- | --- |
| [`blast_card.rb`](blast_card.rb) | Sets a low temperature and asks for the three-line slate |
| [`blast_card_test.rb`](blast_card_test.rb) | Replays the cassette and checks the slate |
| [`cassettes/blast_card.yml`](cassettes/blast_card.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/03-foghorn-timing-card/blast_card.rb
bundle exec ruby features/01-chat-basics/03-foghorn-timing-card/blast_card_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`. The slate is the three lines from the card: a 2 second blast, 18 seconds of silence, and the diaphone. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/03-foghorn-timing-card/blast_card.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
