defmodule AwardsVoter.Web.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  @show_table Application.get_env(:awards_voter, :show_table)
  @ballots_table Application.get_env(:awards_voter, :voter_ballots_table)

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      alias AwardsVoter.Web.Router.Helpers, as: Routes
      import AwardsVoter.TestFixtures

      # The default endpoint for testing
      @endpoint AwardsVoter.Web.Endpoint
    end
  end

  setup do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  setup context do
    if context[:do_show_setup] do
      :dets.open_file(@show_table, [])
      on_exit(fn ->
        :dets.open_file(@show_table, [])
        :dets.delete_all_objects(@show_table)
        :dets.close(@show_table)
      end)
    end
    
    if context[:do_ballots_setup] do
      :dets.open_file(@ballots_table, [])
      on_exit(fn ->
        :dets.open_file(@ballots_table, [])
        :dets.delete_all_objects(@ballots_table)
        :dets.close(@ballots_table)
      end)
    end
    :ok
  end
end
