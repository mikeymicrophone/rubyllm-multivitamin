# Tools · 02 · New Dungeness lens drawer

The lens keeper at New Dungeness Light Station looks up the bullseye
drawer in the Fresnel cabinet. The tool does not declare `parameter`.
The required keyword `drawer:` is the schema.

**What it teaches**

- A required keyword on `execute` becomes a required string property.
- An optional keyword would be optional. This tool has none, so `drawer`
  is the only entry in `required`.
- No description is added unless `parameter` declares one. The property
  is `{ "type": "string" }`.
- `call` checks the keywords before `execute`. A missing keyword and an
  unknown keyword each return `{ error: "Invalid tool arguments: ..." }`.
  They do not raise.
- The mark `ND-4` is only on the tool result. The answer includes it.

**Files**

| File | Role |
| --- | --- |
| [`lens_drawer.rb`](lens_drawer.rb) | Infers `drawer:` and asks for the bullseye drawer |
| [`lens_drawer_test.rb`](lens_drawer_test.rb) | Checks the schema locally and replays the cassette |
| [`cassettes/lens_drawer.yml`](cassettes/lens_drawer.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/02-new-dungeness-lens-drawer/lens_drawer_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/02-new-dungeness-lens-drawer/lens_drawer_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
