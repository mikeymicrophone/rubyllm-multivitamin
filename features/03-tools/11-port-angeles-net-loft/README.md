# Tools · 11 · Port Angeles net loft

The mending ticket at the Port Angeles net loft asks for No. 18 tarred
nylon and for the needle length. Both tools are registered. `choice:`
forces the twine tool. The spool count is 14, and that count is not in
the question.

**What it teaches**

- `with_tool_options(choice: TwineStock)` sends a function `tool_choice`
  whose name is `twine_stock`. The needle tool stays in the `tools` array.
- After the forced call runs, RubyLLM clears the choice. The request that
  asks the model to answer has no `tool_choice`.
- The needle tool does not run, so its "6 inch" sentence is not a tool
  message.

**Files**

| File | Role |
| --- | --- |
| [`twine_stock.rb`](twine_stock.rb) | Registers both tools and forces the twine tool |
| [`twine_stock_test.rb`](twine_stock_test.rb) | Replays the cassette once it exists |
| [`cassettes/twine_stock.yml`](cassettes/twine_stock.yml) | Not recorded yet |

**Try it**

The cassette is not recorded. The test skips with `cassette pending live
recording`.

```sh
bundle exec ruby features/03-tools/11-port-angeles-net-loft/twine_stock_test.rb
```

Record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/03-tools/11-port-angeles-net-loft/twine_stock_test.rb
```

Do not hand-author the cassette.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. It advertises
`tool_choice`. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
