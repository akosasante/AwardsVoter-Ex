defmodule AwardsVoter.Context.Tables.BackupServer do
  @moduledoc """
  Periodically backs up the table files to S3, so that if gigalixir restarts we can recover the data.
  """

  # Only restart if it terminates abnormally. we may want to remove this and keep the default of always restarting :permanent
  use GenServer, restart: :transient

  require Logger

  @bucket_name "awards-voter-backups"
  @default_dets_file_size 5464
  @backup_interval 3_600_000 #backup once every 1 hour

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    Logger.info("Backup Server starting up with args: #{inspect args}")

#    Keyword.get(args, :tables)
#    |> download_tables_if_empty()

    Process.send(self(), :upload_backup, [])

    schedule_work()

    ballot_table_name = Application.get_env(:awards_voter, :ballot_table_name)
    show_table_name = Application.get_env(:awards_voter, :show_table_name)

    {:ok, [tables: [ballot_table_name, show_table_name]]}
  end

  def handle_info(:upload_backup, [tables: tables] = state) do
    for table <- tables do
      if File.exists?("#{table}.dets") do
        Logger.info("#{table} table file exists, uploading to S3")
        upload_to_s3("#{get_s3_prefix()}#{table}.dets")
      else
        Logger.info("#{table} table file not found, skipping upload...")
      end
    end
    schedule_work()
    {:noreply, state}
  end

#  defp download_tables_if_empty(nil), do: nil
#
#  defp download_tables_if_empty(tables) do
#    for table <- tables do
#      download_table_if_empty(table)
#    end
#  end

  def download_table_if_empty(table_name) do
    # Since we auto-create a table file in the application module, we need to check the contents
    case File.stat(table_name) do
      {:ok, %File.Stat{size: file_size}} when file_size > @default_dets_file_size -> Logger.info("#{table_name} already exists and is non-empty (based on file-size), no need to download new one")
      _ ->
        Logger.info("#{table_name} not found or is empty (based on file-size) table, downloading from S3, if available")
        res = download_from_s3(table_name)
        Logger.info("#{table_name} downloaded from S3 with result=#{inspect res}")
    end
  end

  defp download_from_s3(table_name) do
    Logger.debug("downloading from S3")
    @bucket_name
    |> ExAws.S3.download_file("#{get_s3_prefix()}#{table_name}", "./#{table_name}")
    |> ExAws.request(region: "us-east-2")
  end

  defp upload_to_s3(table_name) do
    res = table_name
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(@bucket_name, table_name)
    |> ExAws.request(region: "us-east-2")

    Logger.info("S3 upload completed with result: #{inspect res}")
  end

  defp schedule_work() do
    Process.send_after(self(), :upload_backup, @backup_interval)
  end

  defp get_s3_prefix() do
    if Application.get_env(:awards_voter, :environment) == :prod do
      "prod/"
    else
      "dev/"
    end
  end
end
