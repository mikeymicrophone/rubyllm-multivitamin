# Provider tools and citations · 07 · Lagoon Point file search

The clerk at Lagoon Point, on the west shore of Whidbey, files the
posted card into an OpenAI vector store. `:file_search` without
`vector_store_ids` is a 400. With a prepared store, the citation names
`lagoon-point-card.txt`.

**What it teaches**

- `with_provider_tools(:file_search)` sends `"type":"file_search"` and
  OpenAI answers `Missing required parameter: 'tools[0].vector_store_ids'`.
- `file_search: { vector_store_ids: [id] }` is the OpenAI option.
- `server_tool_calls` includes `file_search_call`.
- File citations expose `title` and `source_id`, not always a URL or
  a response range.
- The vector store is a provider resource. RubyLLM 2.1.1 does not wrap
  create/delete.

**Files**

| File | Role |
| --- | --- |
| [`lagoon_store.rb`](lagoon_store.rb) | Uploads the card, waits on the store, searches, deletes |
| [`lagoon_store_test.rb`](lagoon_store_test.rb) | Replays the cassette |
| [`lagoon-point-card.txt`](lagoon-point-card.txt) | Posted kelp-ledge card |
| [`cassettes/lagoon_store.yml`](cassettes/lagoon_store.yml) | Live OpenAI upload, store, search, and delete |

**Try it**

```sh
bundle exec ruby features/18-provider-tools-and-citations/07-lagoon-point-file-search/lagoon_store_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/18-provider-tools-and-citations/07-lagoon-point-file-search/lagoon_store_test.rb
```

**Model**

`gpt-4.1-mini` with `provider: :openai`. The store uses `purpose: "user_data"`.
Checked 15 October 2026.
