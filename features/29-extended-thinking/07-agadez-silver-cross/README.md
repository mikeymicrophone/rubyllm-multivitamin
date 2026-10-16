# Extended thinking · 07 · Agadez silver cross

The silver desk in Agadez tries to turn thinking off on `gpt-4.1-mini`.
`with_thinking(false)` stores the intent. Reading `chat.thinking`
resolves it and raises: the registry has no off control. No cassette
is written.

**What it teaches**

- `with_thinking(false)` stores a disable intent. `chat.thinking`
  resolves it and raises `ArgumentError`.
- The registry has no off control for `gpt-4.1-mini`.
- This run does not write a cassette.

**Files**

| File | Role |
| --- | --- |
| [`silver_cross.rb`](silver_cross.rb) | Calls `with_thinking(false)` on `gpt-4.1-mini` |
| [`silver_cross_test.rb`](silver_cross_test.rb) | Checks the class and the message |

**Try it**

```sh
bundle exec ruby features/29-extended-thinking/07-agadez-silver-cross/silver_cross.rb
bundle exec ruby features/29-extended-thinking/07-agadez-silver-cross/silver_cross_test.rb
```

No API key is required. Checked 16 October 2026.
