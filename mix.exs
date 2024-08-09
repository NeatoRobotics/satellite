defmodule Satellite.MixProject do
  use Mix.Project

  def project do
    [
      app: :satellite,
      version: "1.0.3",
      elixir: "~> 1.14",
      dialyzer: dialyzer(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp dialyzer do
    [
      plt_add_deps: :app_tree,
      plt_add_apps: [:ex_unit, :mix],
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Satellite.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:redix, "~> 1.3"},
      {:jason, "~> 1.4"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_sqs, "~> 3.3"},
      {:ex_aws_kinesis, "~> 2.0"},
      {:ex_aws_sts, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:broadway, "~> 1.0"},
      {:broadway_sqs, "~> 0.7.1"},
      {:configparser_ex, "~> 4.0"},
      {:ecto_ulid, "~> 0.3"},
      {:ok, "~> 2.3"},
      {:mock, "~> 0.3.0", only: :test},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:logfmt_ex, github: "NeatoRobotics/logfmt_ex", tag: "v0.4.2-fix"},
      {:typed_struct, "~> 0.3.0"},
      {:elixir_avro, "~> 0.1.0"},
      {:avrora, "~> 0.28.0"},
      { :uuid, "~> 1.1" }
    ]
  end
end
