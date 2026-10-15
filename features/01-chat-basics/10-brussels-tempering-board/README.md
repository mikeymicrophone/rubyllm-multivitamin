# Chat basics · 10 · Brussels chocolate tempering board

The chef de laboratoire at Atelier du Grand Sablon reads the same tempering board on two chats. One chat sets `with_temperature` and `with_max_output_tokens`. The other leaves both unset.

**What it teaches**

- `with_temperature` and `with_max_output_tokens` belong to the chat they are called on.
- Until a temperature is set, the request body omits `temperature`. Until an output cap is set, the request omits `max_output_tokens`. OpenAI's Responses API field for the cap is `max_output_tokens`.
- Both chats can still answer from the board: hold the 07:10 Praliné Roi, crystal 31 C.

**Files**

| File | Role |
| --- | --- |
| [`tempering_board.rb`](tempering_board.rb) | Asks the tempering board on a configured chat and on an unset chat |
| [`tempering_board_test.rb`](tempering_board_test.rb) | Replays the cassette and checks the settings and both request bodies |
| [`cassettes/tempering_board.yml`](cassettes/tempering_board.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/10-brussels-tempering-board/tempering_board.rb
bundle exec ruby features/01-chat-basics/10-brussels-tempering-board/tempering_board_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of OpenAI `gpt-4.1-mini`. One request carries `"temperature":0.1` and `"max_output_tokens":2000`. The other request carries neither. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/01-chat-basics/10-brussels-tempering-board/tempering_board.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter `:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback: `gpt-4o-mini`.
