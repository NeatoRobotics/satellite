defmodule Satellite.EventTest do
  use ExUnit.Case
  use OK.Pipe

  alias Satellite.Event
  alias Satellite.Com.Vorwerk.Cleaning.Orbital.V1

  describe "new/1" do
    test "it has default values" do
      event = Event.new(%V1.RobotNotification{message: "hello"})

      assert event.timestamp
      assert %V1.Event{origin: "satellite", payload: %{message: "hello"}} = event
      assert {:ok, %{"payload" => %{"message" => "hello"}}} = V1.Event.to_avro(event)
    end

    test "it can override default values" do
      datetime = DateTime.new!(~D[2016-05-24], ~T[13:26:08.003], "Etc/UTC")

      event =
        Event.new(%V1.RobotNotification{message: "hello"}, %{
          timestamp: datetime,
          origin: "bar"
        })

      assert %V1.Event{
               origin: "bar",
               timestamp: datetime,
               payload: %V1.RobotNotification{message: "hello"}
             } = event

      assert {:ok,
              %{"origin" => "bar", "timestamp" => ^datetime, "payload" => %{"message" => "hello"}}} =
               V1.Event.to_avro(event)
    end
  end

  describe "encode/1" do
    test "it encodes the a robot notification event" do
      event = Event.new(%V1.RobotNotification{message: "hello"})

      {:ok, decoded_event} =
        event
        |> Event.encode()
        ~>> Event.decode()

      assert event == decoded_event
    end

    test "it encodes the event" do
      datetime =
        DateTime.new!(~D[2016-05-24], ~T[13:26:08.003], "Etc/UTC") |> DateTime.to_iso8601()

      event =
        Event.new(%V1.ChargeState{
          charge: 100,
          is_charging: false,
          robot_id: Ecto.UUID.generate(),
          user_id: nil,
          serial: "foo",
          robot_timestamp: datetime
        })

      {:ok, decoded_event} =
        event
        |> Event.encode()
        ~>> Event.decode()

      assert event == decoded_event
    end
  end
end
