defmodule AwardsVoter.Context.Tables.BackupServer do
  @moduledoc """
  Periodically backs up the table files to S3, so that if gigalixir restarts we can recover the data.
  """

  # Only restart if it terminates abnormally. we may want to remove this and keep the default of always restarting :permanent
  use GenServer, restart: :transient

  require Logger

  @bucket_name "awards-voter-backups"

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    Logger.info("Backup Server starting up with args: #{inspect args}")

    Keyword.get(args, :tables)
    |> download_tables_if_empty()

    Process.send(self(), :upload_backup, [])

    schedule_work()

    {:ok, args}
  end

  def handle_info(:upload_backup, [tables: tables] = state) do
    for table <- tables do
      if File.exists?("#{table}.dets") do
        Logger.info("#{table} table file exists, uploading to S3")
        upload_to_s3(table)
      else
        Logger.info("#{table} table file not found, skipping upload...")
      end
    end
    schedule_work()
    {:noreply, state}
  end

  defp download_tables_if_empty(nil), do: nil

  defp download_tables_if_empty(tables) do
    for table <- tables do
      if File.exists?("#{table}.dets") do
        Logger.info("#{table} table file already exists, no need to download new one")
      else
        Logger.info("#{table} table file not found, downloading from S3, if available")
        res = download_from_s3(table)
        Logger.info("#{table} downloaded from S3 with result=#{inspect res}")
      end
    end
  end

  defp download_from_s3(table) do
    @bucket_name
    |> ExAws.S3.download_file("#{table}.dets", "./#{table}.dets")
    |> ExAws.request(region: "us-east-2")
  end

  defp upload_to_s3(table) do
    res = "./#{table}.dets"
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(@bucket_name, "#{table}.dets")
    |> ExAws.request(region: "us-east-2")

    Logger.info("S3 upload completed with result: #{inspect res}")
  end

  defp schedule_work() do
    Process.send_after(self(), :upload_backup, 600_000)
  end
end
