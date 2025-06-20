defmodule QuickFactory.Counters do
  @moduledoc """
  This is a counter module that wraps :counters

  ### Setup
  We can use this in our application by calling `QuickFactory.Counters.start()`
  inside our `test/test_helper.exs` file.

  ### Using Counters
  We can then use this module to add unique integers to each field, each value
  will only be used once provided we continue to call `QuickFactory.Counters.next`

  ```elixir
  QuickFactory.Counters.next("my_schema_field")
  ```
  """

  # This range is more than enough for schemas
  # max range is 4_294_967_296
  # If you have 500k fields you have a problem
  @phash_range 500_000
  @term_key :quick_factory_counter_ref

  @doc """
  This starts the Counters, you need to call this before calling any of the other
  functions in this module. Most commonly this will go in your `test/test_helper.exs` file
  """
  @spec start :: :ok
  def start do
    if :persistent_term.get(@term_key, nil) do
      IO.puts("QuickFactory.Counters already started")
    else
      :persistent_term.put(@term_key, :counters.new(@phash_range, []))
    end
  end

  def reset do
    :persistent_term.put(@term_key, :counters.new(@phash_range, []))
  end

  @doc """
  Increments the counter for a specific key

  ### Example

      iex> key = Enum.random(1..10_000_000)
      iex> QuickFactory.Counters.increment(key)
      :ok
      iex> QuickFactory.Counters.get(key)
      1
  """
  @spec increment(key :: any) :: :ok
  def increment(key) do
    :counters.add(counter_ref(), key_hash(key), 1)
  end

  ## Alias for `increment`
  def inc(key), do: increment(key)

  @doc """
  Puts the counter for a specific key

  ### Example

      iex> key = Enum.random(1..10_000_000)
      iex> QuickFactory.Counters.increment(key)
      :ok
      iex> QuickFactory.Counters.put(key, 1234)
      :ok
      iex> QuickFactory.Counters.get(key)
      1234
  """
  @spec put(key :: any, value :: integer) :: :ok
  def put(key, value) do
    :counters.put(counter_ref(), key_hash(key), value)
  end

  @doc """
  Gets the counter for a specific key

  ### Example

      iex> key = Enum.random(1..10_000_000)
      iex> QuickFactory.Counters.increment(key)
      :ok
      iex> QuickFactory.Counters.get(key)
      1
  """
  @spec get(key :: any) :: integer
  def get(key) do
    :counters.get(counter_ref(), key_hash(key))
  end

  @doc """
  Increments and gets the current value for a specific key

  ### Example

      iex> key = Enum.random(1..10_000_000)
      iex> QuickFactory.Counters.next(key)
      0
      iex> QuickFactory.Counters.next(key)
      1
      iex> QuickFactory.Counters.next(key)
      2
  """
  @spec next(key :: any) :: integer
  def next(key) do
    next_integer = get(key)

    increment(key)

    next_integer
  end

  defp counter_ref, do: :persistent_term.get(@term_key)
  defp key_hash(key), do: :erlang.phash2(key, @phash_range)
end
