# Prompt caching · 11 · Tampere Finlayson card

The mill clerk at Finlayson in Tampere is an agent with a caching macro
and no extra options. Aino counts at 07:00.

**What it teaches**

- `caching` on `RubyLLM::Agent` maps onto `Chat#with_caching`.
- `Agent.new.ask` runs that setup.
- Empty caching sends no `prompt_cache_options`. `ttl:` is slot 02.

**Files**

| File | Role |
| --- | --- |
| [`finlayson_card.rb`](finlayson_card.rb) | Declares the agent, then asks |
| [`finlayson_card_test.rb`](finlayson_card_test.rb) | Checks Aino and the missing options |
| [`cassettes/finlayson_card.yml`](cassettes/finlayson_card.yml) | One Responses POST |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/11-tampere-finlayson-card/finlayson_card.rb
bundle exec ruby features/27-prompt-caching/11-tampere-finlayson-card/finlayson_card_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
