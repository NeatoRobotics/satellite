defmodule Satellite.Bridge.Sink.Redis do
  @behaviour Satellite.Bridge.Sink.Behaviour

  alias Broadway.Message
  require Logger

  def send(%Message{data: event}, %{channel_out: channel}) do
    Logger.info("sending event to channel #{channel}", event: event)

    do_send(event, channel)
  end

  @impl true
  def send(broadway_messages, %{channel_out: _channel} = opts) when is_list(broadway_messages) do
    Logger.info("#{__MODULE__} sending a batch of events to Redis")

    # FIXME: Use Redix pipeline for this
    broadway_messages
    |> OK.map_all(fn message -> OK.wrap(__MODULE__.send(message, opts)) end)
    |> case do
      {:ok, _} -> :ok
      error -> error
    end
  end

  def send(_, opts) do
    msg = "Missing redis configuration parameters"
    Logger.error(msg, opts: opts)

    {:error, msg}
  end

  defp do_send(event, channel, redix_process \\ :satellite_redix) do
    case Redix.command(redix_process, [
           "PUBLISH",
           channel,
           Jason.encode!(event)
         ]) do
      {:ok, _} ->
        :ok

      {:error, %Redix.ConnectionError{reason: :closed} = error} ->
        Logger.error(
          "failed to publish broadcast due to closed redis connection: #{inspect(error)}"
        )

        {:error, :connection_closed}

      {:error, reason} ->
        Logger.error(
          "failed to publish broadcast due to closed redis connection: #{inspect(reason)}"
        )

        {:error, reason}
    end
  end
end
