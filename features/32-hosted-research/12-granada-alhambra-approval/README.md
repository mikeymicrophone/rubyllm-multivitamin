# Hosted research · 12 · Granada Alhambra approval

A Granada ticketing planner validates approval and output-limit assumptions locally before creating any hosted task. This slot makes no HTTP request and has no cassette.

**What it teaches**

- Vertex research rejects MCP approval options and unsupported provider options before HTTP.
- A table of requests and keyword forwarding keep local validation failures inspectable.

**Files**

| File | Role |
| --- | --- |
| [`alhambra_approval.rb`](alhambra_approval.rb) | Hosted research workflow and Ruby idioms |
| [`alhambra_approval_test.rb`](alhambra_approval_test.rb) | Offline behavior and wire assertions |

**Try it**

```sh
bundle exec ruby features/32-hosted-research/12-granada-alhambra-approval/alhambra_approval.rb
bundle exec ruby features/32-hosted-research/12-granada-alhambra-approval/alhambra_approval_test.rb
```

Both failures are local `ArgumentError`s. No task is submitted, no HTTP call is made, and no cassette is needed.
