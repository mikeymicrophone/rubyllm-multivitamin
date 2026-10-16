# Models and providers · 01 · Valencia Fallas commission board

The Junta Central Fallera in Valencia posts the day's chat-model board the
way each falla posts which workshops can take a street's ninots.
`chat_models` is the board. `gpt-4.1-mini`'s context window is the
long-commission clerk who can hold the whole festival list.

**What it teaches**

- `RubyLLM.models.chat_models` returns registry entries whose `type` is
  `:chat`.
- Filters chain: `chat_models.by_provider(:openai)`.
- `context_window` is an Integer or `nil`. The junta posts `gpt-4.1-mini` at
  1_047_576 tokens.
- Listing the bundled registry does not open a socket. There is no
  cassette file; VCR still wraps the run so a later HTTP call fails closed.

**Files**

| File | Role |
| --- | --- |
| [`commission_board.rb`](commission_board.rb) | Lists chat models and reads context windows |
| [`commission_board_test.rb`](commission_board_test.rb) | Checks the board against the bundled registry |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/01-valencia-fallas-board/commission_board.rb
bundle exec ruby features/08-models-and-providers/01-valencia-fallas-board/commission_board_test.rb
```

No API key is required. `LIVE=1` still writes the empty cassette.

**Model**

None. This run never calls a provider.
