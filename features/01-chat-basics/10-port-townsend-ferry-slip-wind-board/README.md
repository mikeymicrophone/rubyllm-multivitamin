# Chat basics · 10 · Port Townsend ferry slip wind board

The slip clerk at Port Townsend reads the same wind board on two chats. One chat sets `with_temperature` and `with_max_output_tokens`. The other leaves both unset.

**What it teaches**

- `with_temperature` and `with_max_output_tokens` belong to the chat they are called on.
- Until a temperature is set, the request body omits `temperature`. Until an output cap is set, the request omits `max_tokens`. OpenRouter's Chat Completions field for the cap is `max_tokens`.
- Both chats can still answer from the board: hold the 07:10 Salish, gust 31 knots.

**Files**

| File | Role |
| --- | --- |
| [`wind_board.rb`](wind_board.rb) | Asks the wind board on a configured chat and on an unset chat |
| [`wind_board_test.rb`](wind_board_test.rb) | Replays the cassette and checks the settings and both request bodies |
| [`cassettes/wind_board.yml`](cassettes/wind_board.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/10-port-townsend-ferry-slip-wind-board/wind_board.rb
bundle exec ruby features/01-chat-basics/10-port-townsend-ferry-slip-wind-board/wind_board_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`. One request carries `"temperature":0.1` and `"max_tokens":2000`. The other request carries neither. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/10-port-townsend-ferry-slip-wind-board/wind_board.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
