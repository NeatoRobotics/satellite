defmodule Satellite.RedisProducer do
  @behaviour Satellite.Producer

  require Logger

  alias Broadway.Message
  alias Satellite.Event

  @impl true
  def send([message = %Message{}], opts), do: __MODULE__.send(message, opts)

  def send(
        %Message{data: event},
        %{channel_out: channel} = _opts
      ) do
    Logger.info("sending event to channel #{channel}", event: event)

    do_send(event, channel)
  end

  def send(%Event{event_type: event_type, origin: origin} = event, _opts) do
    Logger.info("sending event to channel #{origin}:#{event_type}", event: event)

    channel = "#{origin}:#{event_type}"

    do_send(event, channel)
  end

  def send(event, _opts) do
    raise """
      #{__MODULE__} is unable to handle the event #{inspect(event)}
      The event is missing some required fields or is not supported.
    """
  end

  defp do_send(event, channel, redix_process \\ :redix) do
    case Redix.command(redix_process, [
           "PUBLISH",
           channel,
           Jason.encode!(event)
         ]) do
      {:ok, _} ->
        :ok

      {:error, %Redix.ConnectionError{reason: :closed} = error} ->
        Logger.info(
          "failed to publish broadcast due to closed redis connection: #{inspect(error)}"
        )

        {:error, :connection_closed}

      {:error, reason} ->
        Logger.info(
          "failed to publish broadcast due to closed redis connection: #{inspect(reason)}"
        )

        {:error, reason}
    end
  end
end
