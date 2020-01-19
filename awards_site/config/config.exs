# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :awards_site, AwardsSiteWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rBxS5JH8cuz87flZFjiam76wEj7RXW/zsX+CmfHQE+PQypwPIcl1ZrsbufhjZAj6",
  render_errors: [view: AwardsSiteWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AwardsSite.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :awards_voter,
       voter_ballots_table: :voter_ballots,
       show_table: :shows

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
