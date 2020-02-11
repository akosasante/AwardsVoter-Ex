defmodule AwardsVoter.Context.Admin.Shows do
  @moduledoc """
  The Show context.
  """

  alias AwardsVoter.Context.Admin.Shows.Show
  alias Ecto.Changeset

  @type change_result :: {:ok, Show.t()} | {:errors, Changeset.t()}
  
  @spec list_shows(module()) :: {:ok, list(Show.t())} | :error_fetching
  def list_shows(show_manager), do: Show.get_all_shows(show_manager)

  @spec get_show_by_name(String.t()) :: {:ok, Show.t()} | :not_found | :error_finding
  def get_show_by_name(name), do: Show.get_show_by_name(name)

  @spec create_show(map()) :: change_result()
  def create_show(attrs \\ %{}) do
    cs = Show.changeset(%Show{}, attrs)
    with true <- cs.valid?,
         %Show{} = site_show <- Changeset.apply_changes(cs),
         {:ok, saved_show} <- Show.save_or_update_shows(site_show)
      do
      {:ok, saved_show}
    else
      _ -> cs = %{cs | action: :create}
           {:errors, cs}
    end
  end
  
  @spec update_show(Show.t(), map()) :: change_result()
                                        def update_show(%Show{} = orig_show, attrs) do
    cs = Show.changeset(orig_show, attrs)
    with true <- cs.valid?,
         %Show{} = site_show <- Changeset.apply_changes(cs),
         {:ok, saved_show} <- dets_show_update_helper(cs, site_show, orig_show)
      do
      {:ok, saved_show}
    else
      _ -> cs = %{cs | action: :update}
           {:errors, cs}
    end
  end

  @spec delete_show(Show.t()) :: change_result()
  def delete_show(%Show{} = show) do
    case Show.delete_show_entry(show.name) do
      :ok -> {:ok, show}
      e -> {:error, e}
    end
  end

  @spec change_show(Show.t()) :: Changeset.t()
  def change_show(%Show{} = show) do
    Show.changeset(show, %{})
  end

  defp dets_show_update_helper(%Changeset{} = cs, %Show{} = show, %Show{} = original) do
    case Changeset.get_change(cs, :name) do
      nil -> Show.save_or_update_shows(show)
      _updated_title -> case delete_show(original) do
                          {:ok, _deleted_show} -> Show.save_or_update_shows(show)
                          e -> e
                        end
    end
  end
end