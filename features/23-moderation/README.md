# Moderation

`RubyLLM.moderate` returns a `RubyLLM::Moderation`. Read `flagged?`, `flagged_categories`, `category_scores`, and `results` for a batch of strings. `with:` screens images. The default model is OpenAI `omni-moderation-latest`. Bedrock guardrails use `provider: :bedrock` with no generation model. Other attachment types raise `UnsupportedAttachmentError`.

Official reference: [Moderation](https://rubyllm.com/moderation/).

## Models

OpenRouter has no separate moderation operation in 2.1.1. This catalog records OpenAI `omni-moderation-latest`, and pins `omni-moderation-2024-09-26` when a slot needs a dated id. Pre-chat briefs use `gpt-4.1-mini`. Mistral and Bedrock need keys this catalog does not have. Checked 16 October 2026.

## Examples (13 of 13 bottled)

01. [Tamale groundnut paste](01-tamale-groundnut-paste/) — available
02. [Bulawayo township board](02-bulawayo-township-board/) — available
03. [Cusco potato lot](03-cusco-potato-lot/) — available
04. [Avarua tivaevae square](04-avarua-tivaevae-square/) — available
05. [Durban bunny chow](05-durban-bunny-chow/) — available
06. [Guadalajara jarabe studio](06-guadalajara-jarabe-studio/) — available
07. [Georgetown demerara pan](07-georgetown-demerara-pan/) — available
08. [Alice Springs didgeridoo](08-alice-springs-didgeridoo/) — available
09. [Lilongwe maize crib](09-lilongwe-maize-crib/) — available
10. [Arusha booking desk](10-arusha-booking-desk/) — available
11. [Recife frevo atelier](11-recife-frevo-atelier/) — available
12. [Gqeberha cycad nursery](12-gqeberha-cycad-nursery/) — available
13. [Apia siapo print](13-apia-siapo-print/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | Clean hail, `flagged?` false |
| 02 | Flagged slip, `flagged_categories` names violence |
| 03 | Array of comments, one Result each |
| 04 | `with:` image, no caption |
| 05 | `model:` pins `omni-moderation-2024-09-26` |
| 06 | Context `default_moderation_model`, global default stays latest |
| 07 | Caption plus image |
| 08 | WAV raises `UnsupportedAttachmentError` before HTTP |
| 09 | Clean hail still has `category_scores` keys |
| 10 | Screen, then `chat.ask` on a clean card |
| 11 | Rails-style job writes `needs_review` |
| 12 | `raw` keeps OpenAI assessments |
| 13 | Capstone: skip the flagged slip, brief the clean one |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
