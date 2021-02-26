defmodule AwardsVoter.Context.Tables.ShowTable do
  @moduledoc """
  Manages persistence of award show data.
  """
  # Only restart if it terminates abnormally. we may want to remove this and keep the default of always restarting :permanent
  use GenServer, restart: :transient

  alias AwardsVoter.Context.Models.Show
  alias AwardsVoter.Context.Tables.BackupServer

  require Logger

  @type show_tuple :: {id :: String.t(), show :: Show.t()}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    show_table_name = Application.get_env(:awards_voter, :show_table_name)
    if Keyword.get(args, :download_backups) do
      ensure_table_is_available("#{show_table_name}.dets")
    end
    {:ok, _} = :dets.open_file(show_table_name, file: './#{show_table_name}.dets')

    Logger.info("ShowTable starting #{show_table_name}")
    {:ok, [table_name: show_table_name]}
  end

  defp ensure_table_is_available(table_name) do
    BackupServer.download_table_if_empty(table_name)
  end

  ### ====== API ======= ###

  @spec all() :: list(Show.t()) | {:error, term()} | :"$end_of_table"
  def all() do
    GenServer.call(__MODULE__, :get_all)
  end

  @spec get(String.t()) :: Show.t() | :not_found | {:error, term()}
  def get(key) do
    GenServer.call(__MODULE__, {:lookup, key})
  end

  @spec save(nonempty_list(show_tuple())) :: :ok | {:error, term()}
  def save(key_value_tuples) do
    GenServer.call(__MODULE__, {:upsert, key_value_tuples})
  end

  @spec delete(String.t()) :: :ok | {:error, term()}
  def delete(key) do
    GenServer.call(__MODULE__, {:delete, key})
  end

  ### ====== Callback Handlers ======= ###

  def handle_call(:get_all, _from, state) do
    Logger.debug("ShowTable handling :get_all call")

    all =
      case :dets.match(state[:table_name], {:_, :"$1"}) do
        [_ | _] = results_list -> Enum.map(results_list, fn [matched_obj] -> matched_obj end)
        empty_list -> empty_list
      end

    {:reply, all, state}
  end

  def handle_call({:lookup, key}, _from, state) do
    Logger.debug("ShowTable handling :lookup #{inspect(key)} call")

    show =
      case :dets.lookup(state[:table_name], key) do
        [] -> :not_found
        [{_id, saved_show}] -> saved_show
        e -> {:error, e}
      end

    {:reply, show, state}
  end

  def handle_call({:upsert, show_tuples}, _from, state) do
    Logger.debug("ShowTable handling :upsert call")
    res = :dets.insert(state[:table_name], show_tuples)
    {:reply, res, state}
  end

  def handle_call({:delete, key}, _from, state) do
    Logger.debug("ShowTable handling :delete #{key} call")
    res = :dets.delete(state[:table_name], key)
    {:reply, res, state}
  end

  def terminate(reason, state) do
    Logger.info("Terminating ShowTable due to #{inspect(reason)}")
    :dets.close(state[:table_name])
  end
end
