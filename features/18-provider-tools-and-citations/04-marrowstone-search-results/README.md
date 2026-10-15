# Provider tools and citations · 04 · Marrowstone SearchResults RAG

The kelp-ledge cabinet at Marrowstone Point is a stack of posted cards.
`kelp_ledge_cabinet` returns `RubyLLM::SearchResults` so a later model
could cite those passages. On OpenAI the tool message is JSON under
`search_results`. `response.citations` stays empty.

**What it teaches**

- `RubyLLM::SearchResults.new(title:, url:, text:)` is a legal tool return.
- The `:tool` message is `SearchResults#to_json`.
- `SearchResults.from_content` reads that JSON back.
- OpenAI does not turn those passages into `response.citations`.
  Anthropic, Cohere, and Bedrock Converse do.

**Files**

| File | Role |
| --- | --- |
| [`kelp_cards.rb`](kelp_cards.rb) | Searches the Marrowstone cabinet |
| [`kelp_cards_test.rb`](kelp_cards_test.rb) | Replays the cassette |
| [`cassettes/kelp_cards.yml`](cassettes/kelp_cards.yml) | Live OpenAI recording of the cabinet call |

**Try it**

```sh
bundle exec ruby features/18-provider-tools-and-citations/04-marrowstone-search-results/kelp_cards_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/18-provider-tools-and-citations/04-marrowstone-search-results/kelp_cards_test.rb
```

**Model**

`gpt-4.1-mini` with `provider: :openai`. Checked 15 October 2026.
