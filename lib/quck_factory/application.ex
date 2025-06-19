defmodule QuickFactory.Application do
  use Application

  @impl true
  def start(_type, _args) do
    QuickFactory.Counters.start()

    Supervisor.start_link([QuickFactory.Sequence],
      strategy: :one_for_one,
      name: __MODULE__.Supervisor
    )
  end
end
