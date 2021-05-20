# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :approval,
  ecto_repos: [Approval.Repo]

# Configures the endpoint
config :approval, ApprovalWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "T4JSJu22yqhjQmDGNCbkrHw/kfG+SALaKPRx3epy6eBb0T9w+vysnGoWy1EfwaOF",
  render_errors: [view: ApprovalWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Approval.PubSub,
  live_view: [signing_salt: "hLq/6y1B"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
