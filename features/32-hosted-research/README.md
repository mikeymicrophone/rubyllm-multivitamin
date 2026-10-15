# Hosted research

`RubyLLM.research` submits a hosted agent task, waits, and returns a `RubyLLM::Message` (`content`, `citations`, `thinking`, `server_tool_calls`). `agent:` names a hosted agent, not a model id and not a `RubyLLM::Agent` class. `research_later` returns a `RubyLLM::ResearchJob` (`id`, `status`, `refresh`, `wait`, `message`, `cancel`, `tokens`, `cost`). Timeouts raise `ResearchJob::TimeoutError` and leave the task running. `provider_tools:` selects `:mcp` / `:web_search`; allowed remote tools run without approval.

Official reference: [Hosted Research](https://rubyllm.com/hosted-research/).

## RubyLLM 2.1.1 entry points

- `RubyLLM.research(prompt, provider: :vertexai, agent:)`
- `RubyLLM.research_later` → `RubyLLM::ResearchJob`
- `ResearchJob.find(id, provider:)`
- `job.wait`, `refresh`, `cancel`, `message`
- `provider_tools: { mcp: { name:, url: } }`
- `with:` images or PDFs on the prompt

## Providers that can record it

Vertex AI Deep Research (`deep-research-preview-04-2026`, `vertexai_location = "global"`). OpenAI, Anthropic, OpenRouter, and Gemini chat are not this API. OpenAI background Responses jobs are a different feature. This catalog cannot bottle Vertex research without `GOOGLE_CLOUD_PROJECT` credentials. There is no free OpenRouter hosted-research agent.

## Examples (0 of 13 bottled)

01. Richmond Beach Azure Functions docs — planned
02. Edmonds research_later poll — planned
03. Possession Sound Microsoft Learn MCP — planned
04. Gedney job.citations — planned
05. Hat Island with: PDF — planned
06. Priest Point TimeoutError keeps the job — planned
07. Tulalip cancel — planned
08. Camano incomplete max_tokens — planned
09. Saratoga Passage allowed_tools — planned
10. Coupeville cost unknown — planned
11. Penn Cove recover by id — planned
12. Fort Casey approval options raise — planned
13. Admiralty Head research desk capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
