defmodule Satellite.End2End.LoadTest do
  use ExUnit.Case

  alias Satellite.Event
  alias Satellite.Sync

  describe "send/1" do
    setup do
      {:ok, pid} = TestEchoConsumer.start_link()

      on_exit(fn ->
        send(pid, :stop)
      end)

      :ok
    end

    test "basic load testing" do
      work =
        1..4_000
        |> Enum.map(fn i ->
          Event.new(%{type: "foo", payload: %{a: i}})
        end)

      tasks =
        work
        |> Enum.map(fn event ->
          Task.async(fn ->
            start = :os.system_time(:millisecond)
            {:ok, _} = Sync.send(event)
            finish = :os.system_time(:millisecond)

            finish - start
          end)
        end)

      Task.await_many(tasks, 4_000)
    end
  end
end
