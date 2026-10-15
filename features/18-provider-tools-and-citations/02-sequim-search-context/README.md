# Provider tools and citations · 02 · Sequim search context

The tide clerk at Sequim Bay wants the search kept on NOAA. Keyword
options merge onto `:web_search` in the provider's own vocabulary.
`filters.allowed_domains` is a 400 on `gpt-4.1-mini`.
`search_context_size: "low"` is accepted, and the low-context search
still cites.

**What it teaches**

- `with_provider_tools(web_search: { search_context_size: "low" })`
  merges those keys onto `"type":"web_search"`.
- `filters: { allowed_domains: [...] }` raises `RubyLLM::BadRequestError`
  on this model.
- The successful search still fills `response.citations`.

**Files**

| File | Role |
| --- | --- |
| [`sequim_context.rb`](sequim_context.rb) | Tries a domain filter, then a low-context search |
| [`sequim_context_test.rb`](sequim_context_test.rb) | Replays the cassette |
| [`cassettes/sequim_context.yml`](cassettes/sequim_context.yml) | Live OpenAI 400 then a cited search |

**Try it**

```sh
bundle exec ruby features/18-provider-tools-and-citations/02-sequim-search-context/sequim_context_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/18-provider-tools-and-citations/02-sequim-search-context/sequim_context_test.rb
```

**Model**

`gpt-4.1-mini` with `provider: :openai`. Checked 15 October 2026.
