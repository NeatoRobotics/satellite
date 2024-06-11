defmodule Satellite.MixProject do
  use Mix.Project

  def project do
    [
      app: :satellite,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
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
      {:elixir_uuid, "~> 1.2"},
      {:configparser_ex, "~> 4.0"},
      {:avrora, "~> 0.27"},
      {:ecto_ulid, "~> 0.3"}
    ]
  end
end
