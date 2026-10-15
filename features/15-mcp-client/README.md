# MCP client

`RubyLLM::MCP` is the first-party Model Context Protocol client in RubyLLM
2.1.1. Describe a server in a subclass, or build one inline with
`RubyLLM.mcp`. `url` connects over Streamable HTTP. `command` starts a
local process on stdio. `with_mcp` gives a chat that server's tools.
Agents declare the same servers with `mcp`.

`only`, `except`, and `prefix` shape the names the model sees. Resources
are attachments. Prompts are messages you pass to `ask`. A server that
asks for input pauses the chat; `answer` then `complete` finishes the
call. `listen` and `after_change` follow tools that appear while the
watch is open. `extension :tasks` lets a long call return a task.
`defer` keeps a long tool list out of context until the provider
searches. `bearer_token` and `oauth` authorize Streamable HTTP.

Do not add the community `ruby_llm-mcp` gem. It defines the same
`RubyLLM::MCP` constant.

Official reference: [MCP Client](https://rubyllm.com/mcp/) and
[Tool Search](https://rubyllm.com/tool-search/).

## Models

These cassettes were recorded on `gpt-4.1-mini` with `provider: :openai`,
except slot 12 which uses `gpt-5.4-mini`. `gpt-4.1-mini` was on OpenAI's
models list on 14 October 2026 and advertises function calling and
`tool_choice`. It rejects the Responses API `tool_search` tool that
deferred MCP tools need. `gpt-5.4-mini` was the cheapest slug that
accepted a live `tool_search` probe (OpenAI's guide: gpt-5.4 and later;
`gpt-5.4-nano` also 400s). `LIVE_PROVIDER` does not retarget slot 12.
OpenRouter's free chat model remains the alternative for the other
slots: `nvidia/nemotron-3-super-120b-a12b:free`, then
`liquid/lfm-2.5-2.6b:free`.

Slots 01 and 02 also record Streamable HTTP to the public Microsoft
Learn MCP at `https://learn.microsoft.com/api/mcp`. The other slots use
the stdio fixture [`stdio_server.rb`](stdio_server.rb) with a JSON
profile in the scenario folder. Slot 08 speaks HTTP on loopback and
records bearer and OAuth client-credentials.

`LIVE=1 LIVE_PROVIDER=openai` records OpenAI again.
`LIVE=1 LIVE_PROVIDER=openrouter` overwrites a cassette with the free
slug. Replay ignores `LIVE_PROVIDER`. JSON-RPC request ids are random
UUIDs; the cassette player matches MCP bodies with those ids stripped.

## Examples (13 of 13 bottled)

01. [Point Wilson Learn URL](01-point-wilson-learn-url/) — available
02. [New Dungeness inline MCP](02-new-dungeness-inline-mcp/) — available
03. [Cape Disappointment only/except/prefix](03-cape-disappointment-only-prefix/) — available
04. [Friday Harbor with_mcp](04-friday-harbor-with-mcp/) — available
05. [Neah Bay agent mcp macro](05-neah-bay-agent-mcp/) — available
06. [Ediz Hook resource attachment](06-ediz-hook-resource/) — available
07. [Anacortes prompt through ask](07-anacortes-prompt-ask/) — available
08. [Smith Island bearer and OAuth](08-smith-island-bearer/) — available
09. [Bremerton listen and after_change](09-bremerton-listen/) — available
10. [Port Townsend input-request pause](10-port-townsend-input/) — available
11. [Port Angeles background tasks](11-port-angeles-tasks/) — available
12. [Juan de Fuca deferred tool search](12-juan-de-fuca-defer/) — available
13. [Admiralty Inlet capstone](13-admiralty-inlet-capstone/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | A subclass with `url` to Microsoft Learn; `only` keeps search |
| 02 | Inline `RubyLLM.mcp(url:)` when a class is not worth writing |
| 03 | `only`, `except`, and `prefix` on a stdio horn desk |
| 04 | `with_mcp` on a chat, `chat.mcp` by name, `with_mcp(nil)` |
| 05 | Agent `mcp` macro; `Agent.chat.ask` without a separate `with_mcp` |
| 06 | A resource read through the server and attached with `with:` |
| 07 | A prompt filled in and passed to `ask` |
| 08 | `bearer_token` and `oauth grant: :client_credentials` on loopback HTTP |
| 09 | `listen` and `after_change` when a sill card joins the tool list |
| 10 | An input-request pause, `answer`, then `complete` |
| 11 | `extension :tasks`, `awaiting_tasks?`, two `complete` checks |
| 12 | `defer` and `with_mcp(..., defer: true)` so the model searches |
| 13 | Capstone: prefixed tools, a resource, two asks on one desk |
