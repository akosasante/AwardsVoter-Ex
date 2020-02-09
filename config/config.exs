# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :awards_voter,
  voter_ballots_table: :voter_ballots,
  show_table: :shows,
  environment: :prod

# Configures the endpoint
config :awards_voter, AwardsVoter.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "5uqqhOobVkWLOQONgCyv+vdXQDMcBI5E3nzU9cHU4KqvNXjff0ekqS0fwnXGawoo",
  render_errors: [view: AwardsVoter.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AwardsVoter.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "j58+1hoiHwGgzvTUeI+rtaOG2rP1Sv8u"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
