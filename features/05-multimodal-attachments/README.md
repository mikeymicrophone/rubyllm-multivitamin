# Multimodal attachments

`ask` takes files with `with:`. A value can be a path, a URL, an IO, or an array of those. RubyLLM detects the type from the extension and the bytes. Images, video, audio, text, and PDFs are the documented kinds. Build a `RubyLLM::Attachment` yourself to set `resolution:` (`:low`, `:medium`, `:high`, `:ultra_high`, `:original`). A file the provider cannot send raises `RubyLLM::UnsupportedAttachmentError`. `convert_unsupported_attachments` can swap in a text attachment first.

Pick the model from the modality. A text-only free slug will not do this feature.

Official reference: [Attachments](https://rubyllm.com/attachments/).

## Free models

Images and video in: `google/gemma-4-31b-it:free` (image, text, video). Fallback `google/gemma-4-26b-a4b-it:free`, then `dots-studio/dots-3-note-preview:free` for still images only. Audio in: `thinkingmachines/inkling:free`, then `thinkingmachines/inkling-small:free`, then `nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free` (audio, image, and video). PDF: no `:free` chat model advertised `file` input on 14 October 2026. Use a paid model the attachments guide names (`claude-sonnet-5`, or a Gemini model) and record a cassette. Text files ride along with any chat model.

## Examples (0 of 13 bottled)

01. Photograph of the Point Wilson tide board — planned
02. Lens cabinet drawer label — planned
03. Audio of a foghorn timing call — planned
04. PDF of a retort cook procedure — planned
05. Friday Harbor berth map — planned
06. Pilot ladder against the ship's side — planned
07. Buoy tender check-in recording — planned
08. Barometer photograph from the weather round — planned
09. Dry dock sill marks — planned
10. Port Townsend wind board — planned
11. Twine invoice PDF — planned
12. Chart snippet with a correction — planned
13. Tide board photo plus the cook procedure PDF — planned

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | One local image path and a question about the chalked heights |
| 02 | `resolution: :high` on a small label |
| 03 | One audio file; the model is an audio free slug |
| 04 | A PDF on a paid model, cassette recorded, free-model gap noted in the README |
| 05 | A URL the scenario trusts, not a user-supplied path |
| 06 | Two images in one `with:` array |
| 07 | A follow-up ask with no new file, history still describing the recording |
| 08 | A text file of the round beside the photograph |
| 09 | Unsupported type rescued as `UnsupportedAttachmentError` |
| 10 | A converter that turns a spreadsheet into a text attachment |
| 11 | The same PDF asked twice, to show the attachment stays on the user message |
| 12 | Image of a chart; the reply names the correction in the margin |
| 13 | Capstone: image and PDF together, two modalities, two models only if one slug cannot take both |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
