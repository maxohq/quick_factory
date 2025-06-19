defmodule QuickFactoryTest do
  use ExUnit.Case
  doctest QuickFactory

  defmodule MyRepo do
    @moduledoc false
    use Ecto.Repo,
      otp_app: :my_repo,
      adapter: Ecto.Adapters.Postgres
  end

  defmodule MySchema do
    use Ecto.Schema
    import Ecto.Changeset

    schema "my_schemas" do
      field(:foo, :integer)
      field(:bar, :integer)
      field(:foo_bar_baz, :integer)
      field(:mycounter, :integer, default: 0)
    end

    @required_params [:foo, :bar]
    @available_params [:foo_bar_baz, :mycounter | @required_params]

    def changeset(%__MODULE__{} = user, attrs \\ %{}) do
      user
      |> cast(attrs, @available_params)
      |> validate_required(@required_params)
    end
  end

  defmodule TestFactory do
    use QuickFactory,
      schema: MySchema,
      repo: MyRepo,
      changeset: :changeset

    def build(params \\ %{}) do
      default = %{
        foo: 21,
        bar: 42,
        foo_bar_baz: 11,
        mycounter: Counters.next(__MODULE__)
      }

      Map.merge(default, params)
    end
  end

  test "can generate a factory" do
    QuickFactory.Counters.reset()

    assert %MySchema{foo: 21, bar: 42, foo_bar_baz: 11, mycounter: 0} =
             QuickFactory.build(TestFactory)

    assert %MySchema{foo: 21, bar: 10, foo_bar_baz: 11, mycounter: 1} =
             QuickFactory.build(TestFactory, %{bar: 10})

    assert %{foo: 21, bar: 42, foo_bar_baz: 11, mycounter: 2} =
             QuickFactory.build_params(TestFactory)

    assert %{foo: 21, bar: 10, foo_bar_baz: 11, mycounter: 3} =
             QuickFactory.build_params(TestFactory, %{bar: 10})
  end

  test "can generate many factories" do
    assert [_, _] = QuickFactory.build_many_params(2, TestFactory)
  end

  test "can generate a factory with string keys" do
    assert %{
             "foo" => 21,
             "bar" => 42,
             "foo_bar_baz" => 11
           } = QuickFactory.build_params(TestFactory, %{}, keys: :string)
  end

  test "can generate a factory with camelCase keys" do
    assert %{
             "foo" => 21,
             "bar" => 42,
             "fooBarBaz" => 11
           } = QuickFactory.build_params(TestFactory, %{}, keys: :camel_string)
  end
end
