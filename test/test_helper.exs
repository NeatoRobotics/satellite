ExUnit.start()

defmodule Double do
  alias Satellite.Com.Vorwerk.Cleaning.Orbital.V1

  def process(%V1.Event{payload: %V1.Payload{content: content}} = event) do
    key = content |> Map.keys() |> hd
    value = content[key]

    event
    |> put_in([Access.key(:payload), Access.key(:content), key], 2 * value)
    |> OK.wrap()
  end
end

defmodule DoubleWithMetadata do
  alias Satellite.Com.Vorwerk.Cleaning.Orbital.V1

  def process(%V1.Event{payload: %V1.Payload{content: content}} = event) do
    key = content |> Map.keys() |> hd
    value = content[key]
    data = event |> put_in([Access.key(:payload), Access.key(:content), key], 2 * value)

    {:ok, data, %{foo: value}}
  end
end

defmodule TripleWithMetadata do
  alias Satellite.Com.Vorwerk.Cleaning.Orbital.V1

  def process(%V1.Event{payload: %V1.Payload{content: content}} = event) do
    key = content |> Map.keys() |> hd
    value = content[key]
    data = event |> put_in([Access.key(:payload), Access.key(:content), key], 3 * value)

    {:ok, data, %{bar: value}}
  end
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
