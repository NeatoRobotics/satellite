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
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"}
    ]
  end
end
