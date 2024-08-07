defmodule Satellite.Sync.Task do
  alias Satellite.Sync

  require Logger

  def async(event, channel, timeout) do
    Task.async(fn ->
      Sync.subscribe(channel)
      event |> Sync.publish(channel)
      loop(event, channel, timeout)
    end)
  end

  defp loop(event, channel, timeout) do
    receive do
      {:redix_pubsub, _redix_pid, _ref, :message, %{payload: json_payload}} ->
        case Jason.decode!(json_payload) do
          %{"type" => "response"} = payload ->
            Logger.info("Received response to message", event: event, channel: channel)
            Sync.unsubscribe(channel)

            {:ok, payload}

          _ ->
            loop(event, channel, timeout)
        end

      {:DOWN, _, _, _, reason} ->
        Logger.error("Something went wrong")
        Sync.unsubscribe(channel)

        {:error, reason}

      _other ->
        # Keep trying
        loop(event, channel, timeout)
    after
      timeout ->
        Logger.error("Timed out waiting for a response")

        {:error, :timeout}
    end
  end
end
