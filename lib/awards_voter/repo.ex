defmodule AwardsVoter.Repo do
  use Ecto.Repo,
    otp_app: :awards_voter,
    adapter: Ecto.Adapters.Postgres
end
