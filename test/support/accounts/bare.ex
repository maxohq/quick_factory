defmodule QuickFactory.Support.Accounts.Bare do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "account_bare" do
    field(:bare, :string)
  end

  def changeset_update(schema, attrs) do
    schema
    |> cast(attrs, [:bare])
    |> validate_required([:bare])
  end
end
