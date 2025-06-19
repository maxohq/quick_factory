defmodule QuickFactory.Support.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :quick_factory,
    adapter: Ecto.Adapters.Postgres
end
