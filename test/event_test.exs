defmodule Satellite.EventTest do
  use ExUnit.Case

  alias Satellite.Event

  describe "new/1" do
    test "it has default values" do
      event = Event.new(%{type: "test", payload: %{a: 1}})

      assert event.timestamp
      assert %Event{origin: "foo", version: 1, type: "test", payload: %{a: 1}} = event
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
