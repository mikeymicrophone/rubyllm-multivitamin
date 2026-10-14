# Image generation

`RubyLLM.paint` returns an image. `save` writes a file from inline bytes or a hosted URL. `to_blob` and `mime_type` are the bytes and the type. `tokens` and `cost` match the chat readers when the provider reports usage. `with:` edits from reference images. `mask:` is for providers that inpaint. OpenAI-style `count:` asks for several images; the return is an array when more than one comes back.

RubyLLM's OpenRouter image encoder posts to the `images` path, drops `size`, and ignores a `count` above 1. A bottled scenario should assert the request that actually leaves, not the options that were discarded. There is no `:free` image model in the 14 October 2026 catalog, so this feature records a cassette against a paid model and says so.

Official reference: [Image generation](https://rubyllm.com/image-generation/).

## Free models

No `:free` image model. Paid default: `google/gemini-2.5-flash-image` on OpenRouter, which `RubyLLM.paint` already speaks. Seedream and other image models list a zero `image` price and a non-zero `image_output` price; they are not free. Checked 14 October 2026.

## Examples (0 of 13 bottled)

01. Watercolor of the Point Wilson tide board at dusk — planned
02. Cutaway of a Fresnel lens cabinet — planned
03. Fog bank around the foghorn house — planned
04. Cannery retort floor, documentary — planned
05. Friday Harbor floats at blue hour — planned
06. Pilot ladder against a ship's side — planned
07. Bell buoy in a tide race — planned
08. Keeper's weather desk — planned
09. Dry dock gate with a ship on the sill — planned
10. Port Townsend ferry slip in a crosswind — planned
11. Net loft interior — planned
12. Chart table with parallel rulers — planned
13. Edit a lens-cabinet image from a reference — planned

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | Paint, `save`, and assert the file's magic bytes |
| 02 | `mime_type` and `base64?` or `url` from the cassette |
| 03 | Read `tokens` and `cost` when the images response includes usage |
| 04 | A prompt that names the retort, the floor, and the hour |
| 05 | The cassette request has no `size`, even if the call passed one |
| 06 | One image even when `count:` is 4, on OpenRouter |
| 07 | `to_blob` round-trips through `save` |
| 08 | A refused prompt surfaces `BadRequestError` |
| 09 | Provider and `assume_model_exists: true` for a slug the registry lacks |
| 10 | Two prompts, two cassettes interactions, two files |
| 11 | The saved file is gitignored; the cassette is not |
| 12 | Cost is the reported usage cost, not a guessed registry price |
| 13 | Capstone: `with:` a reference image; OpenRouter `input_references` |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
