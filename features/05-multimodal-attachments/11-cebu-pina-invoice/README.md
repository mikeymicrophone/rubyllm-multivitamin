# Multimodal attachments · 11 · Cebu piña invoice

The embroidery shop in Cebu asks twice about one invoice: which bolt and
price, then how many metres. The second question does not attach the PDF.

**What it teaches**

- The same PDF is sent again on a follow-up that attaches nothing.
- The first user message keeps the invoice. The second has no attachment.
- Both requests carry `file_data`. The invoice stays under the inline
  limit, so neither request is a files upload.

**Files**

| File | Role |
| --- | --- |
| [`pina_invoice.rb`](pina_invoice.rb) | Asks twice about the invoice |
| [`pina_invoice_test.rb`](pina_invoice_test.rb) | Replays both turns and checks `file_data` twice |
| [`pina-invoice.pdf`](pina-invoice.pdf) | Bolt 9, 4 metres, 27 dollars |
| [`cassettes/pina_invoice.yml`](cassettes/pina_invoice.yml) | Two Responses round-trips |

**Sample file**

`pina-invoice.pdf` was written for this catalog as a one-page PDF 1.4
file with Helvetica text. The invoice is original.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/11-cebu-pina-invoice/pina_invoice.rb
bundle exec ruby features/05-multimodal-attachments/11-cebu-pina-invoice/pina_invoice_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/11-cebu-pina-invoice/pina_invoice.rb
```

**Model**

`gpt-4.1-mini` on OpenAI.
