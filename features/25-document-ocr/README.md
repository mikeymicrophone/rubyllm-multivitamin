# Document OCR

`RubyLLM.ocr` returns a `RubyLLM::OCR`. `#markdown` joins every page; `#pages` yields `index`, `markdown`, `images`, `tables`, `raw`. Pass `pages:` (zero-based) and `provider_options:` (Mistral `table_format`, `include_image_base64`, `extract_header` / `extract_footer`; Cohere `output_format: "blocks"`). Combine with `with_schema` to structure a scan.

Official reference: [Document OCR](https://rubyllm.com/ocr/).

## RubyLLM 2.1.1 entry points

- `RubyLLM.ocr("contract.pdf")`
- `ocr.markdown` and `ocr.pages`
- `page.index`, `markdown`, `images`, `tables`
- `pages: [0, 1, 2]`
- `provider_options:` table_format / blocks
- `default_ocr_model`

## Providers that can record it

Mistral (`mistral-ocr-latest`: PDFs, office, images). Cohere Parse (`parse-v5.0`: one image per request). OpenAI, Anthropic, Gemini, and OpenRouter have no OCR operation in 2.1.1 (send the file to chat instead). This catalog records on Mistral; it needs `MISTRAL_API_KEY`. There is no free OpenRouter OCR slug.

## Examples (0 of 13 bottled)

01. Gedney cook card scan — planned
02. Hat Island page.markdown — planned
03. Priest Point pages: first three — planned
04. Tulalip HTML tables — planned
05. Camano header and footer — planned
06. Saratoga Passage Cohere blocks — planned
07. Coupeville invoice schema after OCR — planned
08. Penn Cove public URL — planned
09. Fort Casey image-only page — planned
10. Admiralty Head timeout — planned
11. Bush Point rejected file — planned
12. Lagoon Point Active Storage — planned
13. Mutiny Bay chart scan capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
