# Models and providers · 09 · Nairobi ticket-radio preference

The desk at a Nairobi help-ticket radio names `gpt-4.1-mini` without
saying which channel. First-party OpenAI answers. Naming `provider: :azure`
gets the Azure copy of the same id. Naming `provider: :openrouter` gets
the aggregator id `openai/gpt-4.1-mini`.

**What it teaches**

- Bare `find("gpt-4.1-mini")` prefers `openai` over `azure`.
- `provider: :azure` returns the same id on Azure.
- `provider: :openrouter` resolves the alias to `openai/gpt-4.1-mini`.
  The exact id `gpt-4.1-mini` is not in OpenRouter's registry rows.

**Files**

| File | Role |
| --- | --- |
| [`ticket_preference.rb`](ticket_preference.rb) | Resolves the same id bare, on OpenAI, on Azure, and on OpenRouter |
| [`ticket_preference_test.rb`](ticket_preference_test.rb) | Checks the preference order |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/09-nairobi-ticket-radio/ticket_preference.rb
bundle exec ruby features/08-models-and-providers/09-nairobi-ticket-radio/ticket_preference_test.rb
```

No API key is required.

**Model**

None. This run never calls a provider.
