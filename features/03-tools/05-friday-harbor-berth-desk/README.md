# Tools · 05 · Friday Harbor berth desk

The berth clerk at Friday Harbor has two tools. One reads the water under
the float. One reads the clear fender of a numbered berth. The seiner
Kulshan is 48 ft, and the question is whether berth 7 has room. The model
has to pick the length tool.

**What it teaches**

- `with_tools` adds. Calling it again with `BerthLength` leaves
  `FloatDepth` registered.
- `with_tool_options(choice: :required)` sends `"tool_choice":"required"`.
  The model must call a tool. It still chooses which one.
- The length `54 ft` is only in the berth tool. The depth `11.2` should
  not appear in a tool result for this question.

**Files**

| File | Role |
| --- | --- |
| [`berth_desk.rb`](berth_desk.rb) | Registers both tools and asks about berth 7 |
| [`berth_desk_test.rb`](berth_desk_test.rb) | Checks registration locally and the cassette when it exists |
| [`cassettes/berth_desk.yml`](cassettes/berth_desk.yml) | Not recorded yet |

**Try it**

The cassette is not recorded. The chat test skips with `cassette pending
live recording`. The registration test does not call the provider.

```sh
bundle exec ruby features/03-tools/05-friday-harbor-berth-desk/berth_desk_test.rb
```

Record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/03-tools/05-friday-harbor-berth-desk/berth_desk_test.rb
```

Do not hand-author the cassette.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
