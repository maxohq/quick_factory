defmodule QuickFactory.SchemaCounterTest do
  use ExUnit.Case

  setup_all do
    :ok = QuickFactory.SchemaCounter.start()

    %{}
  end

  doctest QuickFactory.SchemaCounter
end
