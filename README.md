# QuickFactory

A lightweight, flexible factory library for Elixir that makes test data generation simple and intuitive.

## Features

- 🚀 **Simple Setup** - Define factories with minimal boilerplate
- 🔧 **Flexible Data Generation** - Build structs, params, or insert directly to database
- ✅ **Changeset Validation** - Optional validation using your schema's changesets
- 🔄 **Batch Operations** - Generate multiple records at once
- 🎯 **Key Transformation** - Support for atom, string, and camelCase keys
- 📊 **Built-in Counters** - Generate unique values across test runs

## Quick Start

### 1. Define a Factory

```elixir
defmodule MyApp.UserFactory do
  use QuickFactory,
    schema: MyApp.User,
    repo: MyApp.Repo,
    changeset: :changeset

  def call(params \\ %{}) do
    %{
      name: "John Doe",
      email: "john@example.com",
      age: 25,
      first_name: "John",
      last_name: "Doe"
    }
    |> Map.merge(params)
  end
end
```

### 2. Generate Test Data

```elixir
# Build a struct
user = UserFactory.build()
#=> %User{name: "John Doe", email: "john@example.com", age: 25}

# Build with custom params
user = UserFactory.build(%{name: "Jane"})
#=> %User{name: "Jane", email: "john@example.com", age: 25}

# Generate params only (great for API testing)
params = UserFactory.build_params(%{age: 30})
#=> %{name: "John Doe", email: "john@example.com", age: 30}

# Insert to database
user = UserFactory.insert!()

# Generate multiple records
users = UserFactory.insert_many!(3)
```

### 3. Key Transformations

Perfect for API testing with different key formats:

```elixir
# Default: atom keys
UserFactory.build_params()
#=> %{name: "John Doe", first_name: "John", last_name: "Doe"}

# String keys
UserFactory.build_params(%{}, keys: :string)
#=> %{"name" => "John Doe", "first_name" => "John", "last_name" => "Doe"}

# CamelCase string keys (great for JSON APIs)
UserFactory.build_params(%{}, keys: :camel_string)
#=> %{"name" => "John Doe", "firstName" => "John", "lastName" => "Doe"}
```

## Installation

Add `quick_factory` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:quick_factory, "~> 0.1.0", only: :test}
  ]
end
```

## Why QuickFactory?

- **Less Magic, More Control** - Explicit factory definitions that are easy to understand
- **Test-Focused** - Built specifically for testing scenarios
- **Ecto Integration** - Works seamlessly with Ecto schemas and changesets
- **Lightweight** - Minimal dependencies and overhead

## Documentation

For full documentation, visit [HexDocs](https://hexdocs.pm/quick_factory).


## Credits

Ideas / Code taken from:
- https://github.com/theblitzapp/factory_ex with simplifications and removals.
- https://github.com/beam-community/ex_machina/blob/main/lib/ex_machina/sequence.ex - nice sequence handling