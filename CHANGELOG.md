### 0.2.1 - 2025-06-19

- (fix): fix flaky tests for QuickFactory.Counters

### 0.2.0 - 2025-06-19

- (breaking): changed the main function from `build` to `call`, so it wont clash with the delegation to `build` on QuickFactory module

- Changed recommended API:
```elixir
## from
QuickFactory.build(UserFactory, name: "Joe")

## to
UserFactory.build(name: "Joe")
```

### 0.1.1 - 2025-06-19

- add sequence handling


### 0.1.0 - 2025-06-19

Initial release.
