# Agents · 02 · New Dungeness lens cabinet

The lens keeper at New Dungeness Light Station reads the bullseye drawer
through a tool declared on the agent class, then tells the gallery watch
the mark on the spare 4th-order panel.

**What it teaches**

- `tools PostedLensDrawer` registers the tool on every chat the agent builds.
- `tool_options choice: PostedLensDrawer` forces that call on the first ask.
- `self.tool_name` keeps the short name `posted_lens_drawer`.
- `execute` returns the posted card as a String. That string is the `:tool`
  message.

**Files**

| File | Role |
| --- | --- |
| [`lens_cabinet.rb`](lens_cabinet.rb) | Declares the tool and the lens-keeper agent |
| [`lens_cabinet_test.rb`](lens_cabinet_test.rb) | Checks the tool message, the mark ND-4, and the roles |
| [`cassettes/lens_cabinet.yml`](cassettes/lens_cabinet.yml) | The Responses round-trips for the forced tool call |

**Try it**

```sh
bundle exec ruby features/14-agents/02-new-dungeness-lens-cabinet/lens_cabinet.rb
bundle exec ruby features/14-agents/02-new-dungeness-lens-cabinet/lens_cabinet_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. `LIVE_PROVIDER=openrouter` overwrites
the cassette with the free slug when that slug advertises tools.

**Model**

`gpt-4.1-mini` on OpenAI. Fallback: OpenRouter
`nvidia/nemotron-3-super-120b-a12b:free`. Checked 15 October 2026.
