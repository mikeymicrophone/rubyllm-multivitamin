# MCP client

A Model Context Protocol server is a `RubyLLM::MCP` subclass. Declare `url`, `stdio`, or `sse`, plus `inputs` and credentials (`bearer_token`, OAuth). `only` and `except` choose tools. `chat.with_mcp` and the agent `mcp` macro attach the server. Resources become attachments; prompts work with `ask`. A server request for input pauses the chat the way tool approvals do. `listen` follows list changes. `RubyLLM::MCP::Task` covers long background tool calls (`done?`, `refresh`, `result`).

Official reference: [MCP Client](https://rubyllm.com/mcp/).

## RubyLLM 2.1.1 entry points

- `class Linear < RubyLLM::MCP`
- `url`, `stdio`, `sse`, `inputs`, `bearer_token`, `only`, `except`
- `chat.with_mcp(Linear.new(user: current_user))`
- agent macro `mcp Files` / `mcp { [Linear.new(user: user)] }`
- `server.tools`, `server.resources`, `server.prompts`
- `listen`, `close`, and `RubyLLM::MCP::Task`

## Providers that can record it

MCP itself is not an LLM provider. The chat turns that call MCP tools record on the chat provider you pick. This catalog's default is OpenRouter `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`. Tool-capable fallback: OpenAI `gpt-4.1-mini`. The MCP server (Linear, GitHub, a local stdio process) is recorded as its own HTTP or stdio traffic beside that chat cassette.

## Examples (0 of 13 bottled)

01. Deception Pass current desk (stdio tide server) — planned
02. Guemes Channel ferry board (HTTP MCP) — planned
03. Rosario Strait traffic list (`only` two tools) — planned
04. Thatcher Pass rename wrap — planned
05. Lopez Sound resource as attachment — planned
06. Eastsound prompt from the server — planned
07. Blakely Island input pause — planned
08. Cypress Island OAuth token — planned
09. Vendovi listen for tool list changes — planned
10. Saddlebag Island task `refresh` — planned
11. Padilla Bay agent `mcp` macro — planned
12. Samish Bay Rails credential store — planned
13. Chuckanut watch desk capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
