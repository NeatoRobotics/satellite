defmodule Satellite.RedisConsumer do
  use GenStage

  require Logger

  alias Broadway.{Message, Acknowledger}

  @behaviour Acknowledger

  @reconnect_after_ms 5_000

  @impl true
  def init(opts) do
    Logger.metadata(module: __MODULE__)
    {opts, client_opts} = Keyword.split(opts, [:broadway])

    opts = %{
      connection_opts: Keyword.fetch!(client_opts, :connection),
      channels: Keyword.fetch!(client_opts, :channels),
      redix_pid: nil,
      reconnect_timer: nil,
      ack_ref: opts[:broadway][:name]
    }

    {:producer, establish_conn(opts)}
  end

  @impl true
  def handle_info(
        {:redix_pubsub, redix_pid, _subscription_ref, :psubscribed, %{pattern: channel}},
        %{redix_pid: redix_pid} = state
      ) do
    Logger.info("successfully subscribed to channel pattern #{channel}")

    {:noreply, [], state}
  end

  @impl true
  def handle_info(
        {:redix_pubsub, redix_pid, _subscription_ref, :subscribed, %{channel: channel}},
        %{redix_pid: redix_pid} = state
      ) do
    Logger.info("successfully subscribed to channel #{channel}")

    {:noreply, [], state}
  end

  @impl true
  def handle_info(
        {:redix_pubsub, redix_pid, _subscription_ref, :unsubscribe, %{channel: channel}},
        %{redix_pid: redix_pid} = state
      ) do
    Logger.info("successfully unsubscribed to channel #{channel}")

    {:noreply, state}
  end

  @impl true
  def handle_info(
        {:redix_pubsub, redix_pid, _subscription_ref, :disconnected, %{error: %{reason: reason}}},
        %{redix_pid: redix_pid} = state
      ) do
    Logger.info(
      "Phoenix.PubSub disconnected from Redis with reason #{inspect(reason)} (awaiting reconnection)"
    )

    {:noreply, state}
  end

  @impl true
  def handle_info(
        {:redix_pubsub, redix_pid, _subscription_ref, :pmessage, message_properties},
        %{redix_pid: redix_pid} = state
      ) do
    Logger.info(
      "Received message #{inspect(message_properties.payload)} of type #{inspect(:message)}"
    )

    forward_message_to_broadway(message_properties, state)
  end

  @impl true
  def handle_info(
        {:redix_pubsub, redix_pid, _subscription_ref, :message, message_properties},
        %{redix_pid: redix_pid} = state
      ) do
    Logger.info(
      "Received message #{inspect(message_properties.payload)} of type #{inspect(:message)}"
    )

    forward_message_to_broadway(message_properties, state)
  end

  @impl true
  def handle_info({:EXIT, redix_pid, _}, %{redix_pid: redix_pid} = state) do
    Logger.info("Received exit message")

    {:noreply, establish_conn(state)}
  end

  @impl true
  def handle_info(:establish_conn, state) do
    {:noreply, establish_conn(%{state | reconnect_timer: nil})}
  end

  @impl true
  def handle_info(message, state) do
    Logger.info("Received unknown message #{inspect(message)}")

    {:noreply, state}
  end

  @impl true
  def handle_demand(_incoming_demand, state) do
    {:noreply, [], state}
  end

  @impl Acknowledger
  def ack(_ack_ref, _successful, _failed) do
    # there is no ack messages for redis pubsub
    :ok
  end

  defp forward_message_to_broadway(message, state) do
    broadway_message = %Message{
      data: message.payload,
      metadata: %{channel: message.channel},
      acknowledger: {__MODULE__, _ack_ref = message.channel, nil}
    }

    {:noreply, [broadway_message], state}
  end

  defp establish_conn(%{connection_opts: connection_opts} = state) do
    case Redix.PubSub.start_link(connection_opts) do
      {:ok, redix_pid} ->
        Logger.info("successfully connected to redis server")
        establish_success(%{state | redix_pid: redix_pid})

      {:error, _} ->
        establish_failed(state)
    end
  end

  defp establish_success(%{redix_pid: redix_pid, channels: channels} = state) do
    for channel <- channels do
      {:ok, _connection} = Redix.PubSub.psubscribe(redix_pid, channel, self())
    end

    state
  end

  defp establish_failed(state) do
    Logger.info("unable to establish initial redis connection. Attempting to reconnect...")

    %{state | redix_pid: nil, reconnect_timer: schedule_reconnect(state)}
  end

  defp schedule_reconnect(%{reconnect_timer: timer}) do
    timer && Process.cancel_timer(timer)
    Process.send_after(self(), :establish_conn, @reconnect_after_ms)
  end

  def publish(redix_pid, channel, message) do
    case Redix.command(redix_pid, ["PUBLISH", channel, Jason.encode!(message)]) do
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