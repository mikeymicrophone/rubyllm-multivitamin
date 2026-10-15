# Image generation · 02 · Seoul ondol flue size

The flue mason at a Bukchon hanok files a square documentary plate of the
ondol stack. `size: "1024x1024"` is the smallest size `gpt-image-1-mini`
accepts, and that is the size on the wire.

**What it teaches**

- `size:` is sent on the images/generations payload for OpenAI.
- `gpt-image-1-mini` accepts `1024x1024`, `1024x1536`, `1536x1024`, and
  `auto`. 256 and 512 are not among them.
- The smallest of those, `1024x1024`, is the bottled default.

**Files**

| File | Role |
| --- | --- |
| [`ondol_flue_size.rb`](ondol_flue_size.rb) | Paints the flue at 1024×1024 |
| [`ondol_flue_size_test.rb`](ondol_flue_size_test.rb) | Replays the cassette |
| [`cassettes/ondol_flue_size.yml`](cassettes/ondol_flue_size.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/07-image-generation/02-seoul-ondol-flue-size/ondol_flue_size_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/07-image-generation/02-seoul-ondol-flue-size/ondol_flue_size_test.rb
```

**Model**

`gpt-image-1-mini`, `size: "1024x1024"`, `quality: "low"`.
