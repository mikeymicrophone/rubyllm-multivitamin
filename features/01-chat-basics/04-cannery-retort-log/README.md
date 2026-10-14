# Chat basics · 04 · Cannery retort log for the morning cook

The retort clerk at the Anacortes cannery logs the morning sockeye cook, takes Calder's correction from the gallery, and writes the office recap. All three asks share one chat.

**What it teaches**

- The first `ask` logs the posted card: basket 3, 240 F, 75 minutes.
- The second `ask` corrects the temperature to 242 F. The basket and the minutes stay.
- The third `ask` recaps the cook. It can name 242 F because the correction is still on the chat.
- The follow-up request is larger than the first. On this OpenRouter recording the earlier assistant turn is sent back with its `reasoning_details`, not only the visible log line.

**Files**

| File | Role |
| --- | --- |
| [`morning_cook.rb`](morning_cook.rb) | Asks for the log line, the correction, and the recap |
| [`morning_cook_test.rb`](morning_cook_test.rb) | Replays the cassette and checks the recap and the next request body |
| [`cassettes/morning_cook.yml`](cassettes/morning_cook.yml) | The three Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/04-cannery-retort-log/morning_cook.rb
bundle exec ruby features/01-chat-basics/04-cannery-retort-log/morning_cook_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`. The recap uses 242 F, basket 3, and 75 minutes. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/04-cannery-retort-log/morning_cook.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
