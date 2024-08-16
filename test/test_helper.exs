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
  def process(x), do: {:ok, x, %{stream_name: "foo"}}
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
