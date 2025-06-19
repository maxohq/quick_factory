defmodule QuickFactory.CountersTest do
  use ExUnit.Case

  setup_all do
    :ok = QuickFactory.Counters.start()

    %{}
  end

  doctest QuickFactory.Counters
end
