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
| [`lens_drawer_test.rb`](lens_drawer_test.rb) | Checks the schema locally and the cassette when it exists |
| [`cassettes/lens_drawer.yml`](cassettes/lens_drawer.yml) | Not recorded yet |

**Try it**

The cassette is not recorded. The chat test skips with `cassette pending
live recording`. The schema test calls the tool directly and does not
need a key.

```sh
bundle exec ruby features/03-tools/02-new-dungeness-lens-drawer/lens_drawer_test.rb
```

Record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/03-tools/02-new-dungeness-lens-drawer/lens_drawer_test.rb
```

Do not hand-author the cassette.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
