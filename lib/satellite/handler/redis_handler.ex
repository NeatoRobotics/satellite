defmodule Satellite.Handler.Redis do
  @behaviour Satellite.Handler.Behaviour

  require Logger

  alias Satellite.Event
  alias Satellite.Com.Vorwerk.Cleaning.Orbital.V1

  # FIXME: Why is the option called :redix_process instead of :name?? How is this working at all?
  @impl true
  def send(%V1.Event{origin: origin} = event, opts \\ [redix_process: redix_process()]) do
    [_version | rest] =
      event.payload.__struct__
      |> Atom.to_string()
      |> String.replace_leading("Elixir.Satellite.Com.Vorwerk.Cleaning.Orbital.", "")
      |> String.split(".")

    type =
      rest
      |> Enum.join("_")
      |> Macro.underscore()

    Logger.info("sending event to channel #{origin}:#{type}", event: event)

    channel = "#{origin}:#{type}"

    publish(event, channel, opts)
  end

  defp publish(%V1.Event{} = event, channel, redix_process: redix_process) do
    {:ok, encoded} = Event.encode(event)

    case Redix.command(redix_process, ["PUBLISH", channel, encoded]) do
      {:ok, _} ->
        :ok

      {:error, %Redix.ConnectionError{reason: :closed} = error} ->
        Logger.info(
          "failed to publish broadcast due to closed redis connection",
          error: error
        )

        {:error, :connection_closed}

      {:error, reason} ->
        Logger.info(
          "failed to publish broadcast due to closed redis connection",
          error: reason
        )

        {:error, reason}
    end
  end

  defp publish(event, channel, _opts) do
    publish(event, channel, redix_process: redix_process())
  end

  def child_spec(opts) do
    name = opts[:name] || :satellite_redix
    redix_opts = opts[:connection] ++ [name: name]
    # NOTE: Can we have a more nuanced way of starting and supervising conns here?
    %{id: __MODULE__, start: {Redix, :start_link, [redix_opts]}}
  end

  defp redix_process do
    {_, handler_opts} = Application.get_env(:satellite, :handler)

    handler_opts[:name] || :satellite_redix
  end
end
