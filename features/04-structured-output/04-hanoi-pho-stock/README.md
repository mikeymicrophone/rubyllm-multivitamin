# Structured output · 04 · Hanoi phở stock card

The kitchen clerk logs the morning kettle as three nested objects: the stock, the stockpot, and the temperatures.

**What it teaches**

- `object` blocks nest `stock`, `vessel`, and `temperatures`.
- Each nested object has its own properties and required list.
- Simmer minutes and Celsius readings come back as integers.

**Files**

| File | Role |
| --- | --- |
| [`stock_card.rb`](stock_card.rb) | Asks for the stock card |
| [`stock_card_test.rb`](stock_card_test.rb) | Replays the cassette |
| [`cassettes/stock_card.yml`](cassettes/stock_card.yml) | Live recording of the schema turn |

**Try it**

```sh
bundle exec ruby features/04-structured-output/04-hanoi-pho-stock/stock_card_test.rb
```

Re-record:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/04-hanoi-pho-stock/stock_card_test.rb
```

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`.
