# Models and providers · 03 · Mindelo morna alias

The radio desk in Mindelo calls the Haiku alias on two station books.
Anthropic answers with a dated id. Bedrock answers with its own catalog
string. The same morna, two register numbers.

**What it teaches**

- `find("claude-haiku-4-5", provider: :anthropic)` resolves the alias to
  `claude-haiku-4-5-20251001`.
- `find(..., provider: :bedrock)` resolves the same alias to
  `anthropic.claude-haiku-4-5-20251001-v1:0`.
- Both entries share family `claude-haiku` and a 200_000 token window.
- Bare `find` without a provider prefers Anthropic, and that entry's id is
  the short name `claude-haiku-4-5`, not the dated alias. Naming the
  provider is what runs the alias table.

**Files**

| File | Role |
| --- | --- |
| [`morna_alias.rb`](morna_alias.rb) | Resolves one alias on two providers, then bare |
| [`morna_alias_test.rb`](morna_alias_test.rb) | Checks the three ids |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/03-mindelo-morna-alias/morna_alias.rb
bundle exec ruby features/08-models-and-providers/03-mindelo-morna-alias/morna_alias_test.rb
```

No API key is required.

**Model**

None. This run never calls a provider.
