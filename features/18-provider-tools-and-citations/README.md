# Provider tools and citations

`chat.with_provider_tools` enables tools that run on the provider: `:web_search`, `:web_fetch` / `:url_context`, `:x_search`, `:code_execution`, `:file_search`, `:image_generation`, `:apply_patch`, `:mcp`. Read `response.server_tool_calls`, `response.citations`, `response.attachments`, `tokens.server_tool_use`. `with_citations` makes attached documents citable. A `RubyLLM::Tool` can return `RubyLLM::SearchResults` so the model cites your RAG hits. `RubyLLM::Citation` has `url`, `title`, `cited_text`, `text`, `start_index`/`end_index`, `start_page`/`end_page`.

Official reference: [Provider Tools](https://rubyllm.com/provider-tools/) and [Citations](https://rubyllm.com/citations/).

## RubyLLM 2.1.1 entry points

- `chat.with_provider_tools(:web_search)`
- `with_provider_tools(web_search: { allowed_domains: [...] })`
- agent macro `provider_tools :web_search`
- `response.server_tool_calls`, `tokens.server_tool_use`
- `chat.with_citations` and `response.citations`
- `RubyLLM::SearchResults` and `RubyLLM::Citation`

## Providers that can record it

Web search: OpenAI/Azure Responses, Anthropic, Gemini/Vertex, xAI, Mistral Conversations, Perplexity (search by default), Bedrock Nova 2, OpenRouter (often `protocol: :responses`). Document citations: Anthropic, Cohere, Bedrock Converse. File search: OpenAI/Azure vector stores, Mistral libraries, Vertex AI Search. An unsupported alias raises `UnsupportedServerToolError` before HTTP. This catalog's cheap record path is OpenAI `gpt-4.1-mini` with `:web_search`, or Anthropic for document `with_citations`. Free OpenRouter slugs rarely advertise hosted tools.

## Examples (0 of 13 bottled)

01. Diamond Point web search hail — planned
02. Sequim tide.gov domain filter — planned
03. Protection Island PDF pages — planned
04. Marrowstone SearchResults RAG — planned
05. Admiralty Head streamed citations — planned
06. Bush Point code_execution — planned
07. Lagoon Point file_search store — planned
08. Mutiny Bay remote MCP pause — planned
09. Useless Bay Gemini search_suggestions — planned
10. Double Bluff with_citations(false) — planned
11. Hood Head agent provider_tools — planned
12. Tala Point citation indexes — planned
13. Termination Point search desk capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
