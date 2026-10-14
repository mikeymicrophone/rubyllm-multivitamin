# Chat basics

`RubyLLM.chat` starts a conversation. `ask` (and its alias `say`) appends a user turn, sends the transcript, and returns a `RubyLLM::Message`. The same chat object keeps `messages`, so a follow-up is another `ask`. `with_instructions` sets the system prompt, `with_temperature` sets sampling when the model accepts it, and `with_model` switches models without rebuilding the transcript. Read `content`, `role`, `finish_reason`, `stopped?`, `tokens`, and `cost` off the message. `response.raw` is the `Faraday::Response`.

A free OpenRouter slug is often missing from the bundled registry. Name `provider: :openrouter` and pass `assume_model_exists: true`. Set `config.openai_use_system_role = true` when the wire role must be `system`; the Chat Completions formatter sends `developer` until that flag is on.

Official reference: [Chat](https://rubyllm.com/chat/).

## Free models

Default `nvidia/nemotron-3-super-120b-a12b:free`. Fallbacks: `liquid/lfm-2.5-2.6b:free`, then `poolside/laguna-s-2.1:free`. Checked 14 October 2026.

## Examples (13 of 13 bottled)

01. [Point Wilson tide board](01-point-wilson-tide-board/) — available
02. [Fresnel lens cabinet inventory](02-fresnel-lens-cabinet-inventory/) — available
03. [Foghorn timing card at Cape Disappointment](03-foghorn-timing-card/) — available
04. [Cannery retort log for the morning cook](04-cannery-retort-log/) — available
05. [Friday Harbor berth assignment](05-friday-harbor-berth-assignment/) — available
06. [Pilot boarding ladder check off Neah Bay](06-pilot-boarding-ladder/) — available
07. [Bell buoy maintenance ledger](07-bell-buoy-maintenance-ledger/) — available
08. [Lighthouse keeper's weather round](08-lighthouse-keepers-weather-round/) — available
09. [Bremerton dry dock gate schedule](09-bremerton-dry-dock-gate-schedule/) — available
10. [Port Townsend ferry slip wind board](10-port-townsend-ferry-slip-wind-board/) — available
11. [Net loft mending ticket](11-net-loft-mending-ticket/) — available
12. [Chart correction for the Strait of Juan de Fuca](12-juan-de-fuca-chart-correction/) — available
13. [Overnight watch handover across several boards](13-overnight-watch-handover/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | Open a chat, set instructions and temperature, ask, then ask again and read roles |
| 02 | One question, one answer, and the message readers (`content`, `role`, `model`, `tokens`, `finish_reason`) |
| 03 | A short card the clerk must not embellish; low temperature |
| 04 | Three turns: the cook, a correction, then a recap that uses both |
| 05 | Several berths in the prompt; the reply names one and `chat.messages` keeps the rest |
| 06 | Two models on one ladder question, then `with_model` for the spare ladder |
| 07 | `say` as the alias, and `chat.messages` printed with roles |
| 08 | A factual round where `stopped?` is the check, not a substring of the prose |
| 09 | Reusing the gate chat versus a fresh chat that never saw the schedule |
| 10 | Temperature and `with_max_output_tokens` set on one chat and left unset on another |
| 11 | Two personas on two chats, and one transcript that grows turn by turn |
| 12 | A tight output cap, an empty or short note, then `response.raw.status` on the posted correction |
| 13 | Capstone: instructions, two boards, a follow-up, roles, finish reason, and tokens |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
