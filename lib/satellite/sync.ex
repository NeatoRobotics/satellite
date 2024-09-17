defmodule Satellite.Sync do
  alias Satellite.Event
  alias Satellite.Handler.Redis
  alias Satellite.Sync.Task, as: SyncTask

  use GenServer

  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    {:ok, _pid} = Redix.PubSub.start_link(host: "127.0.0.1", port: 6379, name: :pubsub_sync)

    {:ok, nil}
  end

  def subscribe(channel) do
    GenServer.cast(__MODULE__, {:subscribe, channel, self()})
  end

  def unsubscribe(channel) do
    GenServer.cast(__MODULE__, {:unsubscribe, channel, self()})
  end

  def publish(event) do
    channel = channel(event)
    GenServer.cast(__MODULE__, {:publish, event, channel})
  end

  def publish(event, channel) do
    GenServer.cast(__MODULE__, {:publish, event, channel})
  end

  @impl true
  def handle_cast({:subscribe, channel, subscriber}, _) do
    {:ok, _ref} = Redix.PubSub.subscribe(:pubsub_sync, channel, subscriber)

    {:noreply, nil}
  end

  @impl true
  def handle_cast({:unsubscribe, channel, subscriber}, _) do
    Redix.PubSub.unsubscribe(:pubsub_sync, channel, subscriber)

    {:noreply, nil}
  end

  @impl true
  def handle_cast({:publish, event, channel}, _) do
    event |> Redis.publish(channel)

    {:noreply, nil}
  end

  @spec send(Event.t()) :: {:ok, term()} | {:error, term()}
  def send(event, timeout \\ 5_000) do
    SyncTask.async(event, channel(event), timeout)
    |> Task.yield()
    |> case do
      {:ok, event_response} ->
        event_response

      {:exit, error} ->
        error

      nil ->
        {:error, :timeout}
    end
  end

  def child_specs(_opts) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, [name: __MODULE__]}}
  end

  defp channel(%Event{id: id, timestamp: timestamp, type: type, origin: origin}) do
    name = "#{id}_#{timestamp}" |> Base.encode64()

    [origin, type, name] |> Enum.join(":")
  end
end
