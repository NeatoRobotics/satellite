import Config

if Mix.env() == :test do
  import_config "test.exs"
end

config :logger, :console,
  level: System.get_env("LOGGER_LEVEL", "critical") |> String.to_atom(),
  format: {LogfmtEx, :format},
  metadata: :all

config :avrora,
  schemas_path: "./priv/schemas"