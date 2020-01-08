import Config

# Print only warnings and errors during test
config :logger,
  level: :warn

config :awards_voter,
  voter_ballots_table: :test_voter_ballots