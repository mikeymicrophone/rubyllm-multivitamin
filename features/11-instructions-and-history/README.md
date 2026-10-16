# Instructions and history

`with_instructions` sets the system prompt and, by default, replaces the one already on the chat. `append: true` adds another. `with_instructions(nil)` clears them. Instructions are `:system` messages in `chat.messages`, and they are sent on every later request.

`chat.messages` is the transcript the model sees. Assigning `chat.messages = chat.messages.last(4)` is how a scenario compacts, redacts, or drops a retracted turn. The user-visible log can be a different array; this feature is about the array that goes on the wire. `add_message` seeds a prior turn without an HTTP call. `chat.messages = []` resets the conversation on the same chat. `with_temperature(nil)` clears a temperature override. Until a temperature is set, the encoder omits the field and the model uses its own default.

On OpenAI's Responses API, system texts ride in the `instructions` field and `input` starts with the user turn. On OpenRouter Chat Completions they are `"role":"system"` messages. `chat.messages` is `:system` in both cases.

Official reference: [Chat](https://rubyllm.com/chat/) (system prompts, transcript, temperature).

## Free models

Recorded on OpenAI `gpt-4.1-mini` after OpenRouter
`nvidia/nemotron-3-super-120b-a12b:free` inverted a Yes/No standing
order on 16 October 2026. `LIVE_PROVIDER=openrouter` records the free
slug when the daily cap allows. Fallbacks:
`liquid/lfm-2.5-2.6b:free`, then `poolside/laguna-s-2.1:free`. The free
slug accepts `temperature`.

## Examples (13 of 13 bottled)

01. [Lyon Jacquard standing orders](01-lyon-jacquard-orders/) — available
02. [Coimbra fado humidity rule appended](02-coimbra-fado-append/) — available
03. [Padua wax cabinet clears instructions](03-padua-wax-clear/) — available
04. [Kuching late-rack follow-up](04-kuching-pepper-follow-up/) — available
05. [Tsukuba Faraday-cup retraction](05-tsukuba-cup-retract/) — available
06. [Hong Kong steamer temperature cleared](06-hong-kong-steamer-temp/) — available
07. [Vienna pit-part sheet](07-vienna-pit-sheet/) — available
08. [Amman mosaic afternoon relief replaces orders](08-amman-mosaic-relief/) — available
09. [Hobart hydrometer message roles](09-hobart-hydrometer-roles/) — available
10. [Trondheim seeded bellows card](10-trondheim-bellows-seed/) — available
11. [Busan sprocket mistake left in](11-busan-sprocket-mistake/) — available
12. [Kanazawa gold-leaf log compacted](12-kanazawa-gold-compact/) — available
13. [Macau fuse-house shift reset](13-macau-fuse-reset/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | One `with_instructions`, and the first `chat.messages` entry is `:system` |
| 02 | `append: true` produces two system messages |
| 03 | `with_instructions(nil)` and the next request has no `instructions` field |
| 04 | The second question does not repeat the drying card; the answer still uses it |
| 05 | Assign `messages` so a fouled Faraday cup is gone from the next request body |
| 06 | First request has `temperature`, the request after `with_temperature(nil)` does not |
| 07 | The system message stays short while the user message carries the pit sheet |
| 08 | Replacing instructions changes the system text on the second request |
| 09 | `messages.map(&:role)` across system, user, assistant |
| 10 | `add_message` seeds last watch; the correction is a user turn |
| 11 | The mistake remains in `messages` and in the next request |
| 12 | A summary, then `messages =` keeps four turns; the cassette drops the middle |
| 13 | Capstone: `messages = []`, new instructions, one more ask |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
