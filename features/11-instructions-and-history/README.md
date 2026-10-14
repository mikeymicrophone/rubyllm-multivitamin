# Instructions and history

`with_instructions` sets the system prompt and, by default, replaces the one already on the chat. `append: true` adds another. `with_instructions(nil)` clears them. Instructions are `:system` messages in `chat.messages`, and they are sent on every later request.

`chat.messages` is the transcript the model sees. Assigning `chat.messages = chat.messages.last(4)` is how a scenario compacts, redacts, or drops a retracted turn. The user-visible log can be a different array; this feature is about the array that goes on the wire. `with_temperature(nil)` clears a temperature override. Until a temperature is set, the encoder omits the field and the model uses its own default.

Official reference: [Chat](https://rubyllm.com/chat/) (system prompts, transcript, temperature).

## Free models

`nvidia/nemotron-3-super-120b-a12b:free`, which accepts `temperature`. Fallbacks: `liquid/lfm-2.5-2.6b:free`, then `poolside/laguna-s-2.1:free`. Checked 14 October 2026.

## Examples (0 of 13 bottled)

01. Tide clerk instructions at Point Wilson — planned
02. A second rule appended for the foghorn watch — planned
03. Clear the instructions when the watch changes — planned
04. A follow-up that only makes sense with the board still in history — planned
05. Drop a retracted sounding from the transcript — planned
06. Temperature set, then cleared — planned
07. A long board under a short instruction — planned
08. Swap instructions between two asks — planned
09. Roles read back from chat.messages — planned
10. The clerk corrects a wrong height on the next turn — planned
11. An earlier assistant mistake left in the transcript on purpose — planned
12. Keep the first and last turns, drop the middle — planned
13. Handover that rewrites instructions when the watch changes — planned

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | One `with_instructions`, and the cassette's first message is `system` |
| 02 | `append: true` produces two system messages |
| 03 | `with_instructions(nil)` and the next request has no system message |
| 04 | The second question does not repeat the board; the answer still uses it |
| 05 | Assign `messages` so a bad sounding is gone from the next request body |
| 06 | First request has `temperature`, the request after `with_temperature(nil)` does not |
| 07 | The system message stays short while the user message carries the board |
| 08 | Replacing instructions changes the system text on the second request |
| 09 | `messages.map(&:role)` across system, user, assistant |
| 10 | The correction is a user turn; the following answer uses the corrected height |
| 11 | The mistake remains in `messages` and in the next request |
| 12 | `messages =` keeps four turns; the cassette body shows only those |
| 13 | Capstone: new instructions, a trimmed transcript, one more ask |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
