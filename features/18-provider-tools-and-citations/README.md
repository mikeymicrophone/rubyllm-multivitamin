# Provider tools and citations

`chat.with_provider_tools` enables tools that run on the provider:
`:web_search`, `:web_fetch` / `:url_context`, `:x_search`,
`:code_execution`, `:file_search`, `:image_generation`, `:apply_patch`,
`:mcp`. Read `response.server_tool_calls`, `response.citations`,
`response.attachments`, `tokens.server_tool_use`. `with_citations` makes
attached documents citable. A `RubyLLM::Tool` can return
`RubyLLM::SearchResults` so the model cites your RAG hits.
`RubyLLM::Citation` has `url`, `title`, `cited_text`, `text`,
`start_index`/`end_index`, `start_page`/`end_page`.

Official reference: [Provider Tools](https://rubyllm.com/provider-tools/)
and [Citations](https://rubyllm.com/citations/).

## RubyLLM 2.1.1 entry points

- `chat.with_provider_tools(:web_search)`
- `with_provider_tools(web_search: { search_context_size: "low" })`
- agent macro `provider_tools :web_search`
- `response.server_tool_calls`, `tokens.server_tool_use`
- `chat.with_citations` and `response.citations`
- `RubyLLM::SearchResults` and `RubyLLM::Citation`

## Models

These cassettes were recorded on OpenAI `gpt-4.1-mini` with
`LIVE=1 LIVE_PROVIDER=openai`. That model speaks the Responses aliases
`:web_search`, `:file_search`, `:code_execution` /
`:code_interpreter`, `:image_generation`, and `:mcp`. `:web_fetch` raises
`UnsupportedServerToolError` before HTTP. Free OpenRouter slugs rarely
advertise hosted tools. Document citations need Anthropic, Cohere, or
Bedrock Converse; this catalog records the OpenAI warning and empty list.

`LIVE_PROVIDER=openrouter` retargets `Multivitamin::Models.chat` on a
live run. Replay ignores it.

## Examples (13 of 13 bottled)

01. [Diamond Point web search hail](01-diamond-point-web-search/) — available
02. [Sequim search context](02-sequim-search-context/) — available
03. [Protection Island PDF citations](03-protection-island-pdf-citations/) — available
04. [Marrowstone SearchResults RAG](04-marrowstone-search-results/) — available
05. [Admiralty Head streamed citations](05-admiralty-head-streamed-citations/) — available
06. [Bush Point code execution](06-bush-point-code-execution/) — available
07. [Lagoon Point file search](07-lagoon-point-file-search/) — available
08. [Mutiny Bay remote MCP](08-mutiny-bay-remote-mcp/) — available
09. [Useless Bay unknown alias](09-useless-bay-unknown-alias/) — available
10. [Double Bluff citations off](10-double-bluff-citations-off/) — available
11. [Hood Head agent provider tools](11-hood-head-agent-tools/) — available
12. [Tala Point citation indexes](12-tala-point-citation-indexes/) — available
13. [Termination Point search desk capstone](13-termination-point-search-desk/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | `:web_search`, `Citation` urls, `web_search_call`, `web_search_requests` |
| 02 | Keyword options; `filters` 400s; `search_context_size: "low"` cites |
| 03 | `with_citations` on a PDF; registry warning; empty document citations |
| 04 | `SearchResults` JSON on the tool message; OpenAI does not cite it |
| 05 | Streamed search; chunk citations; completed `web_search_call` |
| 06 | `:code_execution` → `code_interpreter`; `server_tool_use` stays nil |
| 07 | `file_search` needs `vector_store_ids`; file citation `title` / `source_id` |
| 08 | Hosted `mcp:` connector; `url`/`name` become `server_url`/`server_label` |
| 09 | `:web_fetch` raises `UnsupportedServerToolError` listing OpenAI aliases |
| 10 | `with_citations(false)` does not strip search citations |
| 11 | Agent macro `provider_tools :web_search`; second ask keeps the hail |
| 12 | `start_index`/`end_index` slice equals `citation.text` |
| 13 | Capstone: agent with search and code; two asks on one desk |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
