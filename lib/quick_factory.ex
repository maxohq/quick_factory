defmodule QuickFactory do
  alias QuickFactory.Utils

  @type build_opts :: [
          keys: :atom | :string | :camel_string
        ]

  @doc """
  Callback that returns a map with valid defaults for the schema. <=== THE MAIN CALLBACK
  """
  @callback call(map()) :: map()

  @doc """
  Callback that returns the schema module.
  """
  @callback schema() :: module()

  @doc """
  Callback that returns the schema's repo module.
  """
  @callback repo() :: module()

  @doc """
  Callback that returns which changeset function to use.
  """
  @callback changeset() :: atom()

  @doc """
  Callback that returns a struct with valid defaults for the schema.
  """
  @callback build_struct(map()) :: struct()

  @optional_callbacks [build_struct: 1]

  defmacro __using__(opts) do
    schema = Keyword.fetch!(opts, :schema)
    repo = Keyword.fetch!(opts, :repo)
    changeset = Keyword.get(opts, :changeset, :changeset)

    quote do
      @behaviour QuickFactory
      alias QuickFactory.Counters
      import QuickFactory, only: [sequence: 1, sequence: 2, sequence: 3]

      def schema, do: unquote(schema)
      def repo, do: unquote(repo)
      def changeset, do: unquote(changeset)

      def build_many_params(count, params \\ %{}, opts \\ []) do
        QuickFactory.build_many_params(count, __MODULE__, params, opts)
      end

      def build_params(params \\ %{}, opts \\ []) do
        QuickFactory.build_params(__MODULE__, params, opts)
      end

      def build_invalid_params do
        QuickFactory.build_invalid_params(__MODULE__)
      end

      def build(params \\ %{}, opts \\ []) do
        QuickFactory.build(__MODULE__, params, opts)
      end

      def insert!(params \\ %{}, opts \\ []) do
        QuickFactory.insert!(__MODULE__, params, opts)
      end

      def insert_many!(count, params \\ %{}, opts \\ []) do
        QuickFactory.insert_many!(count, __MODULE__, params, opts)
      end

      def cleanup!(opts \\ []) do
        QuickFactory.cleanup!(__MODULE__, opts)
      end
    end
  end

  @doc """
  Builds many parameters for a schema `changeset/2` function given the factory
  `module` and an optional list/map of `params`.
  """
  @spec build_many_params(pos_integer, module()) :: [map()]
  @spec build_many_params(pos_integer, module(), keyword() | map()) :: [map()]
  @spec build_many_params(pos_integer, module(), keyword() | map(), build_opts) :: [map()]
  def build_many_params(count, module, params \\ %{}, opts \\ []) do
    Enum.map(1..count, fn _ -> build_params(module, params, opts) end)
  end

  @doc """
  Builds the parameters for a schema `changeset/2` function given the factory
  `module` and an optional list/map of `params`.
  """
  @spec build_params(module()) :: map()
  @spec build_params(module(), keyword() | map()) :: map()
  @spec build_params(module(), keyword() | map(), build_opts) :: map()
  def build_params(module, params \\ %{}, opts \\ [])

  def build_params(module, params, opts) when is_list(params) do
    build_params(module, Map.new(params), opts)
  end

  def build_params(module, params, opts) do
    Code.ensure_loaded(module.schema())

    params
    |> module.call()
    |> Utils.deep_struct_to_map()
    |> maybe_encode_keys(opts)
  end

  @spec build_invalid_params(module()) :: map()
  def build_invalid_params(module) do
    params = build_params(module)
    schema = module.schema()
    Code.ensure_loaded(schema)

    field =
      schema.__schema__(:fields)
      |> Kernel.--([:updated_at, :inserted_at, :id])
      |> Enum.reject(&(schema.__schema__(:type, &1) === :id))
      |> Enum.random()

    field_type = schema.__schema__(:type, field)

    field_value =
      case field_type do
        :integer -> "asdfd"
        :string -> 1239
        _ -> 4321
      end

    Map.put(params, field, field_value)
  end

  @doc """
  Builds a schema given the factory `module` and an optional
  list/map of `params`.
  """
  @spec build(module()) :: Ecto.Schema.t()
  @spec build(module(), keyword() | map()) :: Ecto.Schema.t()
  def build(module, params \\ %{}, options \\ [])

  def build(module, params, options) when is_list(params) do
    build(module, Map.new(params), options)
  end

  def build(module, params, options) do
    Code.ensure_loaded(module.schema())
    validate = Keyword.get(options, :validate, true)

    params
    |> module.call()
    |> maybe_changeset(module, validate)
    |> case do
      %Ecto.Changeset{} = changeset -> Ecto.Changeset.apply_action!(changeset, :insert)
      struct when is_struct(struct) -> struct
    end
  end

  @doc """
  Inserts a schema given the factory `module` and an optional list/map of
  `params`. Fails on error.
  """
  @spec insert!(module()) :: Ecto.Schema.t() | no_return()
  @spec insert!(module(), keyword() | map(), Keyword.t()) :: Ecto.Schema.t() | no_return()
  def insert!(module, params \\ %{}, options \\ [])

  def insert!(module, params, options) when is_list(params) do
    insert!(module, Map.new(params), options)
  end

  def insert!(module, params, options) do
    Code.ensure_loaded(module.schema())
    validate? = Keyword.get(options, :validate, true)

    params
    |> module.call()
    |> maybe_changeset(module, validate?)
    |> module.repo().insert!(options)
  end

  @doc """
  Insert as many as `count` schemas given the factory `module` and an optional
  list/map of `params`.
  """
  @spec insert_many!(pos_integer(), module()) :: [Ecto.Schema.t()]
  @spec insert_many!(pos_integer(), module(), keyword() | map()) :: [Ecto.Schema.t()]
  def insert_many!(count, module, params \\ %{}, options \\ []) when count > 0 do
    Enum.map(1..count, fn _ -> insert!(module, params, options) end)
  end

  @doc """
  Removes all the instances of a schema from the database given its factory
  `module`.
  """
  @spec cleanup!(module) :: {integer(), nil | [term()]}
  def cleanup!(module, options \\ []) do
    module.repo().delete_all(module.schema(), options)
  end

  @doc """
  Shortcut for creating unique string values.

  This is automatically imported into a model factory when you `use QuickFactory`.

  This is equivalent to `sequence(name, &"\#{name}\#{&1}")`. If you need to
  customize the returned string, see `sequence/2`.

  Note that sequences keep growing and are *not* reset by ExMachina. Most of the
  time you won't need to reset the sequence, but when you do need to reset them,
  you can use `ExMachina.Sequence.reset/0`.

  ## Examples

      def build(params) do
        %{
          # Will generate "username0" then "username1", etc.
          username: sequence("username")
        }
      end

      def build(params) do
        %{
          # Will generate "Article Title0" then "Article Title1", etc.
          title: sequence("Article Title")
        }
      end
  """
  @spec sequence(String.t()) :: String.t()

  def sequence(name), do: QuickFactory.Sequence.next(name)

  @doc """
  Create sequences for generating unique values.

  This is automatically imported into a model factory when you `use QuickFactory`.

  The `name` can be any term, although it is typically an atom describing the
  sequence. Each time a sequence is called with the same `name`, its number is
  incremented by one.

  The `formatter` function takes the sequence number, and returns a sequential
  representation of that number – typically a formatted string.

  ## Examples

      def build(params) do
        %{
          # Will generate "me-0@foo.com" then "me-1@foo.com", etc.
          email: sequence(:email, &"me-\#{&1}@foo.com"),
          # Will generate "admin" then "user", "other", "admin" etc.
          role: sequence(:role, ["admin", "user", "other"])
        }
      end
  """
  @spec sequence(any, (integer -> any) | nonempty_list) :: any
  def sequence(name, formatter), do: QuickFactory.Sequence.next(name, formatter)

  @doc """
  Similar to `sequence/2` but it allows for passing a `start_at` option
  to the sequence generation.

  ## Examples

      def build(params) do
        %{
          # Will generate "me-100@foo.com" then "me-101@foo.com", etc.
          email: sequence(:email, &"me-\#{&1}@foo.com", start_at: 100),
        }
      end
  """
  @spec sequence(any, (integer -> any) | nonempty_list, start_at: non_neg_integer) :: any
  def sequence(name, formatter, opts), do: QuickFactory.Sequence.next(name, formatter, opts)

  ### private

  defp maybe_encode_keys(params, []), do: params

  defp maybe_encode_keys(params, opts) do
    case opts[:keys] do
      nil -> params
      :atom -> params
      :string -> Utils.stringify_keys(params)
      :camel_string -> Utils.camelize_keys(params)
    end
  end

  defp maybe_changeset(params, module, validate?) do
    if validate? && schema?(module) do
      params = Utils.deep_struct_to_map(params)

      model = struct(module.schema(), %{})
      Kernel.apply(module.schema(), module.changeset(), [model, params])
    else
      struct!(module.schema(), params)
    end
  end

  defp schema?(module) do
    function_exported?(module.schema(), :__schema__, 1)
  end
end
