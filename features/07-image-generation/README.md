# Image generation

`RubyLLM.paint` returns an `Image`. `save` writes a file from inline bytes or
a hosted URL. `to_blob` and `mime_type` are the bytes and the type. `tokens`
and `cost` match the chat readers when the provider reports usage. `count:`
asks for several images; the return is an array when more than one comes
back. `revised_prompt` is the provider's rewrite when one is reported.

These thirteen cassettes were recorded on OpenAI `gpt-image-1-mini` with
`LIVE=1 LIVE_PROVIDER=openai`. That was the cheapest image model on
`https://api.openai.com/v1/models` on 14 October 2026. `dall-e-2` and
`dall-e-3` were gone. The smallest size that model accepts is `1024x1024`.
Every successful paint also sends `provider_options: { quality: "low" }`.
There is no `:free` image model.

Official reference: [Image generation](https://rubyllm.com/image-generation/).

## Models

Recorded on `gpt-image-1-mini` with `provider: :openai`, `size: "1024x1024"`,
and `quality: "low"`. Slot 08 also paints `gpt-image-2`. Slot 07 adds
`1536x1024`. Slot 13 chats with `gpt-4.1-mini` about the saved plate.

`LIVE=1 LIVE_PROVIDER=openai` records OpenAI again. OpenRouter's image
encoder drops `size` and ignores `count` above 1, so these cassettes stay
on OpenAI. Replay ignores `LIVE_PROVIDER`.

## Examples (13 of 13 bottled)

01. [Jaipur kite-tissue board](01-jaipur-kite-tissue-board/) — available
02. [Seoul ondol flue size](02-seoul-ondol-flue-size/) — available
03. [Cremona varnish cutaway](03-cremona-varnish-cutaway/) — available
04. [Isfahan orsi window](04-isfahan-orsi-window/) — available
05. [Havana cigar floor plate](05-havana-cigar-floor-plate/) — available
06. [Tbilisi sulfur-bath prompt](06-tbilisi-sulfur-bath-prompt/) — available
07. [Rila hearth sizes](07-rila-hearth-sizes/) — available
08. [Almaty Medeu models](08-almaty-medeu-models/) — available
09. [Quito pendulum pair](09-quito-pendulum-pair/) — available
10. [Baku pumpjack cost](10-baku-pumpjack-cost/) — available
11. [Chiang Mai umbrella blob](11-chiang-mai-umbrella-blob/) — available
12. [Vilnius stamp size refusal](12-vilnius-stamp-size-refusal/) — available
13. [Sarajevo anvil handover](13-sarajevo-anvil-handover/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | `RubyLLM.paint` returns an `Image`; `model`, `mime_type`, `quality: "low"` |
| 02 | `size: "1024x1024"` is on the request; 256 and 512 are not |
| 03 | `save` writes PNG magic bytes; one HTTP call because `base64?` is true |
| 04 | `url` is nil, `base64?` is true; no `response_format` on the request |
| 05 | `output_format: "jpeg"`; `mime_type` stays `image/png`; bytes are JPEG |
| 06 | `revised_prompt` is nil; the wire keeps the desk's original prompt |
| 07 | Two sizes, two interactions: `1024x1024` then `1536x1024` |
| 08 | `gpt-image-1-mini` then `gpt-image-2`; both ids are in the registry |
| 09 | `count: 2` returns an Array; usage lives on the first image |
| 10 | `tokens.input` and `tokens.output` are set; `cost.total` is nil |
| 11 | `to_blob` equals the bytes `save` wrote |
| 12 | `size: "256x256"` raises `BadRequestError`; cassette is HTTP 400 |
| 13 | Capstone: paint, `save`, `ask` with the saved path as `input_image` |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
