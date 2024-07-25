defmodule Satellite.Bridge.Source.RedisTest do
  use ExUnit.Case

  alias Satellite.Bridge.Source
  alias Satellite.Event
  alias Satellite.Handler.Redis

  describe "get messages" do
    setup do
      client_ops = [
        connection: [host: "127.0.0.1", port: 6379],
        channels: ["robot:*", "user:*"]
      ]

      {:ok, stage} = GenStage.start_link(Source.Redis, client_ops)
      {:ok, _cons} = TestConsumer.start_link(stage)

      :ok
    end

    test "receives events on the channel is listening to" do
      event1 = Event.new(%{type: "foo", origin: "robot", payload: %{a: 1}})
      event2 = Event.new(%{type: "bar", origin: "user", payload: %{b: 1}})

      RedisHandler.send(event1)
      RedisHandler.send(event2)

      json_event1 = Jason.encode!(event1)
      json_event2 = Jason.encode!(event2)

      assert_receive {:received, [message1]}
      assert_receive {:received, [message2]}

      assert message1.data == json_event1
      assert message2.data == json_event2
    end

    test "does not receive events on the channel is not listening to" do
      event = %Event{type: "foo", origin: "other", payload: %{a: 1}}

      RedisHandler.send(event)

      refute_receive {:received, _}
    end
  end
end
