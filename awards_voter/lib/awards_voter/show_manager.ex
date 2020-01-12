defmodule AwardsVoter.ShowManager do
  use GenServer, restart: :transient # Only restart if it terminates abnormally. we may want to remove this and keep the default of always restarting :permanent

  alias AwardsVoter.Show

  require Logger
  
  @show_table Application.get_env(:awards_voter, :show_table)
  
  #CLIENT
  
  def start_link(_args) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end
  
  @spec get(String.t()) :: Show.t() | :not_found | {:error, term()}
  def get(key) do
    GenServer.call(__MODULE__, {:lookup, key})
  end

  @spec put(nonempty_list(Show.show_tuple())) :: :ok | {:error, term()}
  def put(key_value_tuples) do
    GenServer.call(__MODULE__, {:insert, key_value_tuples})
  end

  @spec delete(String.t()) :: :ok | {:error, term()}
  def delete(key) do
    GenServer.call(__MODULE__, {:delete, key})
  end
  
  # SERVER
  
  def init(_args, close_dets_after \\ Mix.env() == :test) do
    Logger.info("Starting ShowManager and opening #{@show_table}")
    {:ok, _name} = :dets.open_file(@show_table, [])
    if close_dets_after do
      :dets.close(@show_table)
    end
    {:ok, @show_table}
  end
  
  def handle_call({:lookup, key}, _from, state) do
    show = case :dets.lookup(@show_table, key) do
      [] -> :not_found
      [{_name, saved_show}] -> saved_show
      e -> {:error, e}
    end
    {:reply, show, state}
  end
  
  def handle_call({:insert, show_tuples}, _from, state) do
    res = :dets.insert(@show_table, show_tuples)
    {:reply, res, state}
  end
  
  def handle_call({:delete, key}, _from, state) do
    res = :dets.delete(@show_table, key)
    {:reply, res, state}
  end
  
  def terminate(reason, _state) do
    Logger.info("Terminating ShowManager due to #{inspect reason}")
    :dets.close(@show_table)
  end
end