# Tools · 01 · Point Wilson tide window

The tide clerk at Point Wilson Light Station does not have the morning
board in the question. A tool with no parameters reads the posted board
and returns it as a string. The watch brief names when the foghorn tender
Alden and the cannery tender Retort can leave the float.

**What it teaches**

- A tool is a subclass of `RubyLLM::Tool` with `description` and `execute`.
- `self.tool_name` is the name on the wire. The default for a nested class
  keeps the module and writes `::` as `--`. This tool overrides it to
  `posted_tide_board`.
- `with_tools` registers the class. RubyLLM 2.1.1 has no `with_tool`.
- `execute` with no keywords publishes an empty object schema.
- A String return is stored as the `:tool` message content, not as JSON.
- `with_tool_options(choice:)` can pin that one tool.
- The times `10:46` and `08:57` are not in the question. They arrive in
  the tool result and the final answer repeats them.
- `with_thinking(false)` sends `"reasoning":{"enabled":false}`.

**Files**

| File | Role |
| --- | --- |
| [`posted_board.rb`](posted_board.rb) | Registers the board tool and asks for the window |
| [`posted_board_test.rb`](posted_board_test.rb) | Replays the cassette once it exists |
| [`cassettes/posted_board.yml`](cassettes/posted_board.yml) | Not recorded yet |

**Try it**

The cassette is not recorded. OpenRouter's free-model daily limit was
exhausted on 14 October 2026 and resets at 2026-10-15 00:00 UTC. The
chat test skips with `cassette pending live recording` until a live run
writes the cassette. The schema test does not call the provider.

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/01-point-wilson-tide-window/posted_board_test.rb
```

Record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/03-tools/01-point-wilson-tide-window/posted_board_test.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any
`sk-or-v1-` token before the file is written. Do not hand-author the cassette.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. It advertises
`tools` and `tool_choice`. Fallback if that slug is gone:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
