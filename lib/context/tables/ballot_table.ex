defmodule AwardsVoter.Context.Tables.BallotTable do
  @moduledoc """
  Manages persistence of voter ballot data.
  """

  # Only restart if it terminates abnormally. we may want to remove this and keep the default of always restarting :permanent
  use GenServer, restart: :transient

  alias AwardsVoter.Context.Models.Ballot

  require Logger
  require Ex2ms

  @type ballot_tuple :: {String.t(), Ballot.t()}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    Logger.info("BallotTable starting #{args[:table_name]}")
    {:ok, args}
  end

  ### ====== API ======= ###

  @spec all() :: list(Ballot.t()) | {:error, term()} | :"$end_of_table"
  def all() do
    GenServer.call(__MODULE__, :get_all)
  end

  @spec all_ballots_for_voter(String.t()) :: list(Ballot.t()) | {:error, term()}
  def all_ballots_for_voter(voter) do
    GenServer.call(__MODULE__, {:list_voter_ballots, voter})
  end

  @spec all_ballots_for_show(String.t()) :: list(Ballot.t()) | {:error, term()}
  def all_ballots_for_show(show) do
    GenServer.call(__MODULE__, {:list_show_ballots, show})
  end

  @spec get_by_id(String.t()) :: Ballot.t() | :not_found | {:error, term()}
  def get_by_id(key) do
    GenServer.call(__MODULE__, {:lookup, key})
  end

  @spec get_by_voter_and_show(String.t(), String.t()) ::
          Ballot.t() | :not_found | {:error, term()}
  def get_by_voter_and_show(voter, show) do
    GenServer.call(__MODULE__, {:get_ballot_by_voter_and_show, voter, show})
  end

  @spec save(nonempty_list(ballot_tuple())) :: :ok | {:error, term()}
  def save(key_value_tuples) do
    GenServer.call(__MODULE__, {:upsert, key_value_tuples})
  end

  @spec delete(String.t()) :: :ok | {:error, term()}
  def delete(key) do
    GenServer.call(__MODULE__, {:delete, key})
  end

  ### ====== Callback Handlers ======= ###

  def handle_call(:get_all, _from, state) do
    Logger.debug("BallotTable handling :get_all call")

    all =
      case :dets.match(state[:table_name], {:_, :"$1"}) do
        [_ | _] = results_list -> Enum.map(results_list, fn [matched_obj] -> matched_obj end)
        empty_list_or_error -> empty_list_or_error
      end

    {:reply, all, state}
  end

  def handle_call({:list_voter_ballots, voter}, _from, state) do
    Logger.debug("Handling :list_voter_ballots for #{inspect(voter)} call")

    match_spec =
      Ex2ms.fun do
        {_, %{voter: voter}} = ballot_tuple when voter == ^voter -> ballot_tuple
      end

    results =
      case :dets.select(state[:table_name], match_spec) do
        [_ | _] = results_list -> Enum.map(results_list, fn {_id, ballot} -> ballot end)
        empty_list_or_error -> empty_list_or_error
      end

    {:reply, results, state}
  end

  def handle_call({:list_show_ballots, show}, _from, state) do
    Logger.debug("Handling :list_voter_ballots for #{inspect(show)} call")

    match_spec =
      Ex2ms.fun do
        {_, %{show_id: show_id}} = ballot_tuple when show_id == ^show -> ballot_tuple
      end

    results =
      case :dets.select(state[:table_name], match_spec) do
        [_ | _] = results_list -> Enum.map(results_list, fn {_id, ballot} -> ballot end)
        empty_list_or_error -> empty_list_or_error
      end

    {:reply, results, state}
  end

  def handle_call({:lookup, key}, _from, state) do
    Logger.debug("BallotTable handling :lookup #{inspect(key)} call")

    ballot =
      case :dets.lookup(state[:table_name], key) do
        [] -> :not_found
        [{_id, saved_ballot}] -> saved_ballot
        e -> {:error, e}
      end

    {:reply, ballot, state}
  end

  def handle_call({:get_ballot_by_voter_and_show, voter, show}, _from, state) do
    Logger.debug(
      "BallotTable handling :get_ballot_by_voter_and_show #{inspect({voter, show})} call"
    )

    match_spec =
      Ex2ms.fun do
        {_, %{show_id: show_id, voter: voter}} = ballot_tuple
        when voter == ^voter and show_id == ^show ->
          ballot_tuple
      end

    ballot =
      case :dets.select(state[:table_name], match_spec) do
        [] -> :not_found
        [{_id, matching_ballot} | _] -> matching_ballot
        empty_list_or_error -> empty_list_or_error
      end

    {:reply, ballot, state}
  end

  def handle_call({:upsert, ballot_tuples}, _from, state) do
    Logger.debug("BallotTable handling :upsert call")
    res = :dets.insert(state[:table_name], ballot_tuples)
    {:reply, res, state}
  end

  def handle_call({:delete, key}, _from, state) do
    Logger.debug("BallotTable handling :delete #{key} call")
    res = :dets.delete(state[:table_name], key)
    {:reply, res, state}
  end

  def terminate(reason, state) do
    Logger.info("Terminating BallotTable due to #{inspect(reason)}")
    :dets.close(state[:table_name])
  end
end
