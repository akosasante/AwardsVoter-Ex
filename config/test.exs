import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
# config :awards_voter, AwardsVoter.Repo,
#  username: "postgres",
#  password: "postgres",
#  database: "awards_voter_test#{System.get_env("MIX_TEST_PARTITION")}",
#  hostname: "localhost",
#  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :awards_voter, AwardsVoter.Web.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :awards_voter,
       show_table_name: :test_show_table,
       ballot_table_name: :test_ballot_table,
       run_backups: false

config :ex_aws,
       access_key_id: "test",
       secret_access_key: "test"

config :awards_voter, environment: :test
