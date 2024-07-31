defmodule Bridge.Integration.Redis2SQSTest do
  use ExUnit.Case
  import Mock

  alias Satellite.Bridge.Sink.Kinesis
  alias Satellite.Handler
  alias Satellite.Event

  describe "event processing" do
    test "it only processes events once" do
      with_mock Kinesis, [:passthrough],
        send: fn _message, _opts ->
          :ok
        end do
        event1 = Event.new(%{type: "foo", origin: "robot", payload: %{a: 1}})
        Handler.Redis.send(event1)

        :timer.sleep(1_000)

        assert_called_exactly(Kinesis.send(:_, :_), 1)
      end
    end
  end
end
