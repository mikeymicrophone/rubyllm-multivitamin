# Chat basics

`RubyLLM.chat` starts a conversation. `ask` (and its alias `say`) appends a user turn, sends the transcript, and returns a `RubyLLM::Message`. The same chat object keeps `messages`, so a follow-up is another `ask`. `with_instructions` sets the system prompt, `with_temperature` sets sampling when the model accepts it, and `with_model` switches models without rebuilding the transcript. Read `content`, `role`, `finish_reason`, `stopped?`, `tokens`, and `cost` off the message. `response.raw` is the `Faraday::Response`.

A free OpenRouter slug is often missing from the bundled registry. Name `provider: :openrouter` and pass `assume_model_exists: true`. Set `config.openai_use_system_role = true` when the wire role must be `system`; the Chat Completions formatter sends `developer` until that flag is on.

Official reference: [Chat](https://rubyllm.com/chat/).

## Free models

Default `nvidia/nemotron-3-super-120b-a12b:free`. Fallbacks: `liquid/lfm-2.5-2.6b:free`, then `poolside/laguna-s-2.1:free`. Checked 14 October 2026.

## Examples (13 of 13 bottled)

01. [Bengaluru inverter board](01-bengaluru-inverter-board/) — available
02. [Bologna manuscript cabinet](02-bologna-manuscript-cabinet/) — available
03. [Chronometer timing card at La Chaux-de-Fonds](03-chaux-de-fonds-timing-card/) — available
04. [Lagos ankara bale log for the morning receiving](04-lagos-ankara-bale-log/) — available
05. [Dakar Biennale booth assignment](05-dakar-biennale-booth/) — available
06. [Tallinn readiness probe check](06-tallinn-readiness-probe/) — available
07. [Buenos Aires bandoneón ledger](07-buenos-aires-bandoneon-ledger/) — available
08. [Johannesburg clinic vitals round](08-johannesburg-clinic-vitals/) — available
09. [Mexico City soundstage call sheet](09-mexico-city-soundstage-call/) — available
10. [Brussels chocolate tempering board](10-brussels-tempering-board/) — available
11. [Kyoto kimono atelier ticket](11-kyoto-kimono-atelier/) — available
12. [Accession tag for the Singapore Botanic Gardens](12-singapore-accession-tag/) — available
13. [Warsaw tram depot handover across several boards](13-warsaw-tram-depot-handover/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | Open a chat, set instructions and temperature, ask, then ask again and read roles |
| 02 | One question, one answer, and the message readers (`content`, `role`, `model`, `tokens`, `finish_reason`) |
| 03 | A short card the clerk must not embellish; low temperature |
| 04 | Three turns: the receiving, a correction, then a recap that uses both |
| 05 | Several booths in the prompt; the reply names one and `chat.messages` keeps the rest |
| 06 | Two models on one probe question, then `with_model` for the spare timeout |
| 07 | `say` as the alias, and `chat.messages` printed with roles |
| 08 | A factual round where `stopped?` is the check, not a substring of the prose |
| 09 | Reusing the call-sheet chat versus a fresh chat that never saw the sheet |
| 10 | Temperature and `with_max_output_tokens` set on one chat and left unset on another |
| 11 | Two personas on two chats, and one transcript that grows turn by turn |
| 12 | A tight output cap, an empty or short note, then `response.raw.status` on the posted correction |
| 13 | Capstone: instructions, two boards, a follow-up, roles, finish reason, and tokens |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
