defmodule QuickFactory.Support.Accounts.Role do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset, only: [cast: 3, validate_required: 2]

  alias QuickFactory.Support.Accounts.{User, Role}

  schema "account_roles" do
    field(:code, :string)

    has_many(:users, User)
  end

  @required_params [:code]

  def changeset(%Role{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, @required_params)
    |> validate_required(@required_params)
  end
end
