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
        Event.new(%{
          timestamp: datetime,
          origin: "bar",
          version: 2,
          type: "test",
          payload: %{a: 1}
        })

      assert %Event{
               origin: "bar",
               timestamp: ^datetime,
               version: 2,
               type: "test",
               payload: %{a: 1}
             } = event
    end
  end
end
