# Tools · 06 · Neah Bay pilot window

The mate off Neah Bay starts with a tide tool, clears it, and registers
the pilot ladder window. The ladder times are not in the question.

**What it teaches**

- `with_tools(nil)` clears every registered tool. A later `with_tools`
  starts a new set. RubyLLM 2.1.1 has no `with_tool`.
- The cleared tool's name is absent from the request body.
- The open times `09:10` and `11:40` come back on the tool message and
  in the answer.

**Files**

| File | Role |
| --- | --- |
| [`pilot_window.rb`](pilot_window.rb) | Clears the tide tool, then asks for the ladder window |
| [`pilot_window_test.rb`](pilot_window_test.rb) | Checks the cleared set locally and the cassette when it exists |
| [`cassettes/pilot_window.yml`](cassettes/pilot_window.yml) | Not recorded yet |

**Try it**

The cassette is not recorded. The chat test skips with `cassette pending
live recording`.

```sh
bundle exec ruby features/03-tools/06-neah-bay-pilot-window/pilot_window_test.rb
```

Record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/03-tools/06-neah-bay-pilot-window/pilot_window_test.rb
```

Do not hand-author the cassette.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
