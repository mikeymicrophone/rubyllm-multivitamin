# Multimodal attachments · 11 · Port Angeles twine invoice

The net loft at Port Angeles asks two questions about one twine invoice.
The second `ask` does not attach the PDF again.

**What it teaches**

- The first user message keeps the invoice. The second user message has
  no attachment.
- Both requests still contain `file_data` for that PDF. The follow-up
  body is larger because it also carries the first answer.
- `auto_upload_large_files` is on, and both calls go to `/v1/responses`.
  There is no `file_id`. The invoice is under the 50 MiB inline limit,
  so the base64 is stored twice. The card itself is under 1 KB.

**Files**

| File | Role |
| --- | --- |
| [`twine_invoice.rb`](twine_invoice.rb) | Asks for the hank, then for the pounds |
| [`twine_invoice_test.rb`](twine_invoice_test.rb) | Replays the cassette and checks both `file_data` parts |
| [`twine-invoice.pdf`](twine-invoice.pdf) | Hank 14, manila, 3 pounds, 18 dollars |
| [`cassettes/twine_invoice.yml`](cassettes/twine_invoice.yml) | The two Responses round-trips |

**Sample file**

`twine-invoice.pdf` was written for this catalog as a one-page PDF 1.4
file with Helvetica text. The invoice is original.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/11-port-angeles-twine-invoice/twine_invoice.rb
bundle exec ruby features/05-multimodal-attachments/11-port-angeles-twine-invoice/twine_invoice_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/11-port-angeles-twine-invoice/twine_invoice.rb
```

**Model**

`gpt-4.1-mini` on OpenAI.
