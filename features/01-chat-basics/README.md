# Chat basics

`RubyLLM.chat` starts a conversation. `ask` (and its alias `say`) appends a user turn, sends the transcript, and returns a `RubyLLM::Message`. The same chat object keeps `messages`, so a follow-up is another `ask`. `with_instructions` sets the system prompt, `with_temperature` sets sampling when the model accepts it, and `with_model` switches models without rebuilding the transcript. Read `content`, `role`, `finish_reason`, `stopped?`, `tokens`, and `cost` off the message. `response.raw` is the `Faraday::Response`.

A free OpenRouter slug is often missing from the bundled registry. Name `provider: :openrouter` and pass `assume_model_exists: true`. Set `config.openai_use_system_role = true` when the wire role must be `system`; the Chat Completions formatter sends `developer` until that flag is on.

Official reference: [Chat](https://rubyllm.com/chat/).

## Free models

Default `nvidia/nemotron-3-super-120b-a12b:free`. Fallbacks: `liquid/lfm-2.5-2.6b:free`, then `poolside/laguna-s-2.1:free`. Checked 14 October 2026.

## Examples (1 of 13 bottled)

01. [Point Wilson tide board](01-point-wilson-tide-board/) — available
02. Fresnel lens cabinet inventory — planned
03. Foghorn timing card at Cape Disappointment — planned
04. Cannery retort log for the morning cook — planned
05. Friday Harbor berth assignment — planned
06. Pilot boarding ladder check off Neah Bay — planned
07. Bell buoy maintenance ledger — planned
08. Lighthouse keeper's weather round — planned
09. Bremerton dry dock gate schedule — planned
10. Port Townsend ferry slip wind board — planned
11. Net loft mending ticket — planned
12. Chart correction for the Strait of Juan de Fuca — planned
13. Overnight watch handover across several boards — planned

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | Open a chat, set instructions and temperature, ask, then ask again and read roles |
| 02 | One question, one answer, and the message readers (`content`, `finish_reason`) |
| 03 | A short card the clerk must not embellish; low temperature |
| 04 | Three turns: the cook, a correction, then a recap that uses both |
| 05 | Several berths in the prompt; the reply names one and the transcript keeps the rest |
| 06 | Switch `with_model` between two free slugs on the second question |
| 07 | `say` as the alias, and `chat.messages` printed with roles |
| 08 | A factual round where `stopped?` is the check, not a substring of the prose |
| 09 | A schedule long enough that the second ask would be wrong without history |
| 10 | Temperature left unset on one chat and set on another |
| 11 | Replace nothing yet: just show the transcript growing turn by turn |
| 12 | Read `response.raw.status` beside the parsed message |
| 13 | Capstone: instructions, two boards, a follow-up, roles, finish reason, and tokens |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
