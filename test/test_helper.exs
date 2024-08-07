ExUnit.start()

defmodule Double do
  def process(x), do: {:ok, 2 * x}
end

defmodule DoubleWithMetadata do
  def process(x), do: {:ok, 2 * x, %{foo: x}}
end

defmodule TripleWithMetadata do
  def process(x), do: {:ok, 3 * x, %{bar: x}}
end

defmodule IdentityProcessor do
  def process(x), do: {:ok, x}
end

defmodule Fail do
  def process(_x), do: {:error, :service_error}
end

defmodule TestConsumer do
  def start_link(producer) do
    GenStage.start_link(__MODULE__, {producer, self()})
  end

  def init({producer, owner}) do
    {:consumer, owner, subscribe_to: [producer]}
  end

  def handle_events(events, _from, owner) do
    send(owner, {:received, events})
    {:noreply, [], owner}
  end
end

defmodule TestEchoConsumer do
  alias Satellite.Handler.Redis
  use GenServer

  def start_link() do
    {:ok, pubsub} = Redix.PubSub.start_link()
    {:ok, redis_client} = Redix.start_link()
    GenServer.start_link(__MODULE__, {pubsub, redis_client})
  end

  @impl true
  def init({pubsub, redis_client}) do
    Task.start(fn ->
      {:ok, _ref} = Redix.PubSub.psubscribe(pubsub, "satellite:*", self())
      loop(pubsub, redis_client)
    end)

    {:ok, self()}
  end

  @impl true
  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end

  defp loop(pubsub, redis_client) do
    receive do
      {:redix_pubsub, _pubsub, _ref, :pmessage, %{channel: channel, payload: json_data}} ->
        event_data = json_data |> Jason.decode!(keys: :atoms)

        case event_data do
          %{type: "response"} ->
            :noop

          %{type: "timeout"} ->
            :noop

          %{type: "fail"} ->
            Task.start(fn ->
              event_data = event_data |> Map.merge(%{type: "response", payload: "error"})
              event = struct(Satellite.Event, event_data)
              :timer.sleep(100)
              event |> Redis.publish(channel, redix_process: redis_client)
            end)

          _ ->
            Task.start(fn ->
              event_data = event_data |> Map.merge(%{type: "response"})
              event = struct(Satellite.Event, event_data)
              :timer.sleep(100)
              event |> Redis.publish(channel, redix_process: redis_client)
            end)
        end

        loop(pubsub, redis_client)

      _other ->
        loop(pubsub, redis_client)
    end
  end
end
