# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :awards_voter,
  show_table_name: :dev_show,
  ballot_table_name: :dev_ballot,
  run_backups: true

# Configures the endpoint
config :awards_voter, AwardsVoter.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    System.get_env("SECRET_KEY_BASE", "insecure-dev-and-test-key-only-set-SECRET_KEY_BASE-in-prod-0123456789"),
  render_errors: [view: AwardsVoter.Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: AwardsVoter.PubSub,
  live_view: [signing_salt: "n04BFKW8"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
