use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :awards_voter, AwardsVoterWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :awards_voter, AwardsVoter.Repo,
  username: "postgres",
  password: "postgres",
  database: "awards_voter_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
