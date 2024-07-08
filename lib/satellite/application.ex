defmodule Satellite.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = children()

    opts = [strategy: :one_for_one, name: Satellite.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def children() do
    [
      child_specs(Application.get_env(:satellite, :handler)),
      child_specs(Application.get_env(:satellite, :bridge)),
      child_specs({Satellite.Bridge, []})
    ]
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  defp child_specs(entries) when is_list(entries) do
    entries |> Enum.map(&child_specs/1)
  end

  defp child_specs({handler, opts}) do
    opts
    |> handler.child_spec()
  end

  defp child_specs(_) do
    nil
  end
end
