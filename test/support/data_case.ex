defmodule AwardsVoter.DataCase do
#  @moduledoc """
#  This module defines the setup for tests requiring
#  access to the application's data layer.
#
#  You may define functions here to be used as helpers in
#  your tests.
#
#  Finally, if the test case interacts with the database,
#  it cannot be async. For this reason, every test runs
#  inside a transaction which is reset at the beginning
#  of the test unless the test case is marked as async.
#  """
#
  use ExUnit.CaseTemplate
  @show_table Application.get_env(:awards_voter, :show_table)
  @ballots_table Application.get_env(:awards_voter, :voter_ballots_table)
  
  using do
    quote do
      import AwardsVoter.TestFixtures
    end
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
#
#  setup tags do
#    :ok = Ecto.Adapters.SQL.Sandbox.checkout(AwardsVoter.Repo)
#
#    unless tags[:async] do
#      Ecto.Adapters.SQL.Sandbox.mode(AwardsVoter.Repo, {:shared, self()})
#    end
#
#    :ok
#  end
#
#  @doc """
#  A helper that transforms changeset errors into a map of messages.
#
#      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
#      assert "password is too short" in errors_on(changeset).password
#      assert %{password: ["password is too short"]} = errors_on(changeset)
#
#  """
#  def errors_on(changeset) do
#    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
#      Enum.reduce(opts, message, fn {key, value}, acc ->
#        String.replace(acc, "%{#{key}}", to_string(value))
#      end)
#    end)
#  end
end
