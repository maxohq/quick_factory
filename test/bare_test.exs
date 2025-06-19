defmodule QuickFactoryBareTest do
  use ExUnit.Case

  defmodule MyRepo do
    use Ecto.Repo,
      otp_app: :my_repo,
      adapter: Ecto.Adapters.Postgres
  end

  defmodule TestFactory do
    use QuickFactory,
      schema: QuickFactory.Support.Accounts.Bare,
      repo: MyRepo,
      changeset: :changeset_update

    def call(params \\ %{}) do
      %{
        bare: "33",
        funky: sequence("funky")
      }
      |> Map.merge(params)
    end
  end

  alias QuickFactory.Support.Accounts.Bare

  test "can generate a factory" do
    ## without changeset validation
    assert %Bare{bare: 1000, funky: "funky0"} =
             QuickFactory.build(TestFactory, [bare: 1000], validate: false)

    ## with changeset validation - keyword list
    assert %Bare{bare: "45", funky: "funky1"} =
             QuickFactory.build(TestFactory, [bare: "45"], validate: true)

    ## with changeset validation - map
    assert %Bare{bare: "10"} = QuickFactory.build(TestFactory, %{bare: "10"})

    ## build_params: without arguments
    assert %{bare: "33"} = QuickFactory.build_params(TestFactory)

    ## build_params: with arguments
    assert %{bare: "10"} = QuickFactory.build_params(TestFactory, %{bare: "10"})
  end
end
