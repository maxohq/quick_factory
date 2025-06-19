defmodule QuickFactory.Utils do
  @moduledoc false

  @struct_fields [:__meta__]
  @whitelisted_modules [NaiveDateTime, DateTime, Date, Time]
  @camelize_regex ~r/(?:^|[-_])|(?=[A-Z][a-z])/

  @doc """
  Changes structs into maps all the way down, excluding
  things like DateTime.
  """
  @spec deep_struct_to_map(any) :: any
  def deep_struct_to_map(%module{} = struct) when module in @whitelisted_modules do
    struct
  end

  def deep_struct_to_map(struct) when is_struct(struct) do
    struct
    |> Map.from_struct()
    |> Map.drop(@struct_fields)
    |> deep_struct_to_map()
  end

  def deep_struct_to_map(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {k, deep_struct_to_map(v)} end)
  end

  def deep_struct_to_map(list) when is_list(list) do
    Enum.map(list, &deep_struct_to_map/1)
  end

  def deep_struct_to_map(elem) do
    elem
  end

  def underscore_schema(ecto_schema) when is_atom(ecto_schema) do
    ecto_schema |> inspect |> underscore_schema
  end

  def underscore_schema(ecto_schema) do
    ecto_schema |> String.replace(".", "") |> Macro.underscore()
  end

  def context_schema_name(ecto_schema) do
    ecto_schema
    |> String.split(".")
    |> Enum.take(-2)
    |> Enum.map_join("_", &Macro.underscore/1)
  end

  @doc """
  Converts all string keys to string

  ### Example

      iex> QuickFactory.Utils.stringify_keys(%{"test" => 5, hello: 4})
      %{"test" => 5, "hello" => 4}

      iex> QuickFactory.Utils.stringify_keys([%{"a" => 5}, %{b: 2}])
      [%{"a" => 5}, %{"b" => 2}]
  """
  @spec stringify_keys(Enum.t()) :: Enum.t()
  def stringify_keys(map) do
    transform_keys(map, fn
      key when is_binary(key) -> key
      key when is_atom(key) -> Atom.to_string(key)
    end)
  end

  @spec camelize_keys(Enum.t()) :: Enum.t()
  def camelize_keys(map) do
    transform_keys(map, fn
      key when is_binary(key) -> camelize(key, :lower)
      key when is_atom(key) -> camelize(to_string(key), :lower)
    end)
  end

  defp transform_keys(map, transform_fn) when is_map(map) do
    Enum.into(map, %{}, fn {key, value} ->
      {transform_fn.(key), transform_keys(value, transform_fn)}
    end)
  end

  defp transform_keys(list, transform_fn) when is_list(list) do
    Enum.map(list, &transform_keys(&1, transform_fn))
  end

  defp transform_keys(item, _transform_fn), do: item

  def camelize(word, option \\ :upper) do
    case Regex.split(@camelize_regex, to_string(word)) do
      words ->
        words
        |> Enum.filter(&(&1 != ""))
        |> camelize_list(option)
        |> Enum.join()
    end
  end

  defp camelize_list([], _), do: []

  defp camelize_list([h | tail], :lower) do
    [String.downcase(h)] ++ camelize_list(tail, :upper)
  end

  defp camelize_list([h | tail], :upper) do
    [String.capitalize(h)] ++ camelize_list(tail, :upper)
  end
end
