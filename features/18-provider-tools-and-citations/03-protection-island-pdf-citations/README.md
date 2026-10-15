# Provider tools and citations · 03 · Protection Island PDF citations

The landing clerk at Protection Island reads the posted auklet card, a
one-page PDF, and asks `with_citations` to mark the page. `gpt-4.1-mini`
still reads 240 birds and 10:46. Document citations stay empty. The
registry warns that this model does not support them.

**What it teaches**

- `chat.with_citations` is a flag. On this model it warns
  `does not support citations`.
- `ask(..., with: pdf)` still sends the page as `input_file`.
- `response.citations` is empty. Anthropic, Cohere, and Bedrock Converse
  cite attached documents; this OpenAI recording does not.

**Files**

| File | Role |
| --- | --- |
| [`auklet_card.rb`](auklet_card.rb) | Reads the Protection Island PDF with citations on |
| [`auklet_card_test.rb`](auklet_card_test.rb) | Replays the cassette |
| [`auklet-card.pdf`](auklet-card.pdf) | Posted auklet and kelp-ledge card |
| [`cassettes/auklet_card.yml`](cassettes/auklet_card.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/18-provider-tools-and-citations/03-protection-island-pdf-citations/auklet_card_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/18-provider-tools-and-citations/03-protection-island-pdf-citations/auklet_card_test.rb
```

**Model**

`gpt-4.1-mini` with `provider: :openai`. Checked 15 October 2026.
