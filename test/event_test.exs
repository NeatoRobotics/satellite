defmodule Satellite.EventTest do
  use ExUnit.Case

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
    test "it encodes the event" do
      event = Event.new(%V1.RobotNotification{message: "hello"})

      assert {:ok, <<79, 98, 106, 1, 3, 204, 2, 20, 97, 118, 114, 111, 46, 99, 111, 100, 101, 99,
               8, 110, 117, 108, 108, 22, 97, 118, 114, 111, 46, 115, 99, 104, 101, 109, 97,
               144, 2, 123, 34, 110, 97, 109, 101, 115, 112, 97, 99, 101, 34, 58, 34, 105,
               111, 46, 99, 111, 110, 102, 108, 117, 101, 110, 116, 34, 44, 34, 110, 97, 109,
               101, 34, 58, 34, 80, 97, 121, 109, 101, 110, 116, 34, 44, 34, 116, 121, 112,
               101, 34, 58, 34, 114, 101, 99, 111, 114, 100, 34, 44, 34, 102, 105, 101, 108,
               100, 115, 34, 58, 91, 123, 34, 110, 97, 109, 101, 34, 58, 34, 105, 100, 34,
               44, 34, 116, 121, 112, 101, 34, 58, 34, 115, 116, 114, 105, 110, 103, 34, 125,
               44, 123, 34, 110, 97, 109, 101, 34, 58, 34, 97, 109, 111, 117, 110, 116, 34,
               44, 34, 116, 121, 112, 101, 34, 58, 34, 100, 111, 117, 98, 108, 101, 34, 125,
               93, 125, 0, 138, 124, 66, 49, 157, 51, 242, 3, 33, 52, 161, 147, 221, 174,
               114, 48, 2, 26, 8, 116, 120, 45, 49, 123, 20, 174, 71, 225, 250, 47, 64, 138,
               124, 66, 49, 157, 51, 242, 3, 33, 52, 161, 147, 221, 174, 114, 48>>} = Event.encode(event)
    end
  end
end
