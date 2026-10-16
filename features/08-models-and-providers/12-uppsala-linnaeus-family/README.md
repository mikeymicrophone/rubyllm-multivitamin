# Models and providers · 12 · Uppsala Linnaeus family

The herbarium clerk in Uppsala files clerks by family, the way the
Linnaean cabinet files genera. A name that merely contains "sonnet" does
not put a clerk in the Claude Sonnet drawer.

**What it teaches**

- `RubyLLM.models.by_family("claude-sonnet")` matches the `family` field.
- Every entry on that list has `family == "claude-sonnet"`.
- Some registry ids contain `"sonnet"` with another family, or none.
  Those stay off the family list. A substring scrape of every id would
  have filed them wrong.
- `Models#find` looks up an id. A block on that call is `ArgumentError`.
  Walk `.all.find` when you want Enumerable's finder.

**Files**

| File | Role |
| --- | --- |
| [`plant_family.rb`](plant_family.rb) | Filters by family and compares a substring scrape |
| [`plant_family_test.rb`](plant_family_test.rb) | Asserts the family field, not the id |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/12-uppsala-linnaeus-family/plant_family.rb
bundle exec ruby features/08-models-and-providers/12-uppsala-linnaeus-family/plant_family_test.rb
```

No API key is required.

**Model**

None. This run never calls a provider.
