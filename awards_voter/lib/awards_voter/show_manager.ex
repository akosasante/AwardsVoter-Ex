defmodule AwardsVoter.ShowManager do
  use GenServer, restart: :transient # Only restart if it terminates abnormally. we may want to remove this and keep the default of always restarting :permanent

  alias AwardsVoter.Show

  require Logger
  
  @show_table Application.get_env(:awards_voter, :show_table)
  
  #CLIENT
  
  def start_link(_args) do
    open_table(:pid)
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end
  
  @spec all() :: list(Show.t()) | {:error, term()} | :"$end_of_table"
  def all() do
    GenServer.call(__MODULE__, :get_all)
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
  
  def init(_args) do
    Logger.info("Starting ShowManager")
    
    Logger.info("Self iit: #{inspect self()}")
    {:ok, @show_table}
  end
  
  def handle_call(:get_all, _from, state) do
    :dets.match_object(@show_table, :_)
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
    Logger.info "Handling :insert call"
    res = :dets.insert(@show_table, show_tuples)
    {:reply, res, state}
  end
  
  def handle_call({:delete, key}, _from, state) do
    res = :dets.delete(@show_table, key)
    {:reply, res, state}
  end
  
  def handle_info(msg, state) do
    IO.inspect(msg)
    IO.inspect(state)
    {:noreply, state}
  end
  
  def terminate(reason, _state) do
    Logger.info("Terminating ShowManager due to #{inspect reason}")
    :dets.close(@show_table)
  end
  
  defp open_table(pid, close_dets_after \\ Mix.env() == :test) do
    {:ok, _name} = :dets.open_file(@show_table, [])
    Logger.info("Self open_table: #{inspect self()} DETS: #{inspect :dets.info(@show_table, :owner)}, info: #{inspect :dets.info(@show_table, :owner)}")
    if close_dets_after do
      :dets.close(@show_table)
    end
  end
end