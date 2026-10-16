# Image generation · 07 · Rila hearth sizes

The kitchen at Rila Monastery wants a square plate of the hearth and a
landscape plate of the same hearth against the courtyard colonnade. Two
`paint` calls, two sizes, two interactions.

**What it teaches**

- Two paint calls with two sizes produce two request bodies.
- `1024x1024` is square. `1536x1024` is the landscape size this model lists.
- Each call is its own images/generations interaction.

**Files**

| File | Role |
| --- | --- |
| [`hearth_sizes.rb`](hearth_sizes.rb) | Paints the hearth at two sizes |
| [`hearth_sizes_test.rb`](hearth_sizes_test.rb) | Replays the cassette |
| [`cassettes/hearth_sizes.yml`](cassettes/hearth_sizes.yml) | Two live OpenAI recordings |

**Try it**

```sh
bundle exec ruby features/07-image-generation/07-rila-hearth-sizes/hearth_sizes_test.rb
```

**Model**

`gpt-image-1-mini`, first `size: "1024x1024"`, then `size: "1536x1024"`.
