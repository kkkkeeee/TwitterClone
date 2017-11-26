use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.

config :phoenix_integration,
  endpoint: App.Endpoint

config :app, App.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :app, App.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "phoenix_twitter_test",
  hostname: "127.0.0.1",
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 600_000
