import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :awards_voter, AwardsVoter.Web.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :awards_voter,
   voter_ballots_table: :test_voter_ballots,
   show_table: :test_show_table

# Configure your database
#config :awards_voter, AwardsVoter.Repo,
#  username: "postgres",
#  password: "postgres",
#  database: "awards_voter_test",
#  hostname: "localhost",
#  pool: Ecto.Adapters.SQL.Sandbox
