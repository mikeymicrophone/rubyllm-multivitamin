# Instructions and history

`with_instructions` sets the system prompt and, by default, replaces the one already on the chat. `append: true` adds another. `with_instructions(nil)` clears them. Instructions are `:system` messages in `chat.messages`, and they are sent on every later request.

`chat.messages` is the transcript the model sees. Assigning `chat.messages = chat.messages.last(4)` is how a scenario compacts, redacts, or drops a retracted turn. The user-visible log can be a different array; this feature is about the array that goes on the wire. `add_message` seeds a prior turn without an HTTP call. `chat.messages = []` resets the conversation on the same chat. `with_temperature(nil)` clears a temperature override. Until a temperature is set, the encoder omits the field and the model uses its own default.

On OpenAI's Responses API, system texts ride in the `instructions` field and `input` starts with the user turn. On OpenRouter Chat Completions they are `"role":"system"` messages. `chat.messages` is `:system` in both cases.

Official reference: [Chat](https://rubyllm.com/chat/) (system prompts, transcript, temperature).

## Free models

Recorded on OpenAI `gpt-4.1-mini` after OpenRouter
`nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded:
free-models-per-day` on 14 October 2026. `LIVE_PROVIDER=openrouter`
records the free slug when the daily cap allows. Fallbacks:
`liquid/lfm-2.5-2.6b:free`, then `poolside/laguna-s-2.1:free`. The free
slug accepts `temperature`.

## Examples (13 of 13 bottled)

01. [Point Wilson kelp-ledge standing orders](01-point-wilson-clerk-orders/) — available
02. [Cape Disappointment horn rule appended](02-cape-disappointment-horn-append/) — available
03. [New Dungeness watch clears instructions](03-new-dungeness-watch-clear/) — available
04. [Anacortes late-basket follow-up](04-anacortes-basket-follow-up/) — available
05. [Ediz Hook retracted sounding](05-ediz-hook-retracted-sounding/) — available
06. [Port Townsend temperature cleared](06-port-townsend-temperature-clear/) — available
07. [Friday Harbor long slip sheet](07-friday-harbor-slip-sheet/) — available
08. [Bremerton afternoon relief replaces orders](08-bremerton-afternoon-relief/) — available
09. [Smith Island message roles](09-smith-island-message-roles/) — available
10. [Neah Bay seeded ladder card](10-neah-bay-seeded-ladder/) — available
11. [Mukilteo range-light mistake left in](11-mukilteo-left-mistake/) — available
12. [Juan de Fuca overnight log compacted](12-juan-de-fuca-log-compact/) — available
13. [Admiralty Inlet watch reset](13-admiralty-inlet-watch-reset/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | One `with_instructions`, and the first `chat.messages` entry is `:system` |
| 02 | `append: true` produces two system messages |
| 03 | `with_instructions(nil)` and the next request has no `instructions` field |
| 04 | The second question does not repeat the cook card; the answer still uses it |
| 05 | Assign `messages` so a fouled sounding is gone from the next request body |
| 06 | First request has `temperature`, the request after `with_temperature(nil)` does not |
| 07 | The system message stays short while the user message carries the slip sheet |
| 08 | Replacing instructions changes the system text on the second request |
| 09 | `messages.map(&:role)` across system, user, assistant |
| 10 | `add_message` seeds last watch; the correction is a user turn |
| 11 | The mistake remains in `messages` and in the next request |
| 12 | A summary, then `messages =` keeps four turns; the cassette drops the middle |
| 13 | Capstone: `messages = []`, new instructions, one more ask |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
