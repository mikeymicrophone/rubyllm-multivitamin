# Chat basics · 04 · Lagos ankara bale log for the morning receiving

The receiving clerk at a Balogun Market wholesale house in Lagos logs the morning ankara wax bale, takes Kemi's correction from the mezzanine, and writes the office recap. All three asks share one chat.

**What it teaches**

- The first `ask` logs the posted card: bale 3, 240 yards, 75 pieces.
- The second `ask` corrects the length to 242 yards. The bale and the piece count stay.
- The third `ask` recaps the receiving. It can name 242 yards because the correction is still on the chat.
- The follow-up request is larger than the first. On this OpenRouter recording the earlier assistant turn is sent back with its `reasoning_details`, along with the visible log line.
- The recap may print bale 3 with a narrow no-break space (U+202F) between the word and the number. A check for a normal space misses it.

**Files**

| File | Role |
| --- | --- |
| [`morning_bale.rb`](morning_bale.rb) | Asks for the log line, the correction, and the recap |
| [`morning_bale_test.rb`](morning_bale_test.rb) | Replays the cassette and checks the recap and the next request body |
| [`cassettes/morning_bale.yml`](cassettes/morning_bale.yml) | The three Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/04-lagos-ankara-bale-log/morning_bale.rb
bundle exec ruby features/01-chat-basics/04-lagos-ankara-bale-log/morning_bale_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`. The recap uses 242 yards, bale 3, and 75 pieces. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/04-lagos-ankara-bale-log/morning_bale.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
