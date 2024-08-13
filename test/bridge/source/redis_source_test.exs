defmodule Satellite.Bridge.Source.RedisTest do
  use ExUnit.Case

  alias Satellite.Bridge.Source
  alias Satellite.Event
  alias Satellite.Handler
  alias Satellite.Com.Vorwerk.Cleaning.Orbital.V1

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
      datetime =
        DateTime.new!(~D[2016-05-24], ~T[13:26:08.003], "Etc/UTC") |> DateTime.to_iso8601()

      event1 = Event.new(%V1.RobotNotification{message: "foo"}, %{origin: "robot"})

      event2 =
        Event.new(
          %V1.ChargeState{
            charge: 100,
            is_charging: false,
            robot_id: Ecto.UUID.generate(),
            user_id: nil,
            serial: "foo",
            robot_timestamp: datetime
          },
          %{origin: "user"}
        )

      Handler.Redis.send(event1)
      Handler.Redis.send(event2)

      assert_receive {:received, [message1]}
      :timer.sleep(100)
      assert_receive {:received, [message2]}

      assert Event.decode(message1.data) == {:ok, event1}
      assert Event.decode(message2.data) == {:ok, event2}
    end

    test "does not receive events on the channel is not listening to" do
      event = Event.new(%V1.RobotNotification{message: "foo"}, %{origin: "other"})

      Handler.Redis.send(event)

      refute_receive {:received, _}
    end
  end
end
