defmodule Satellite.Sync.TaskTest do
  use ExUnit.Case

  alias Satellite.Sync.Task, as: SyncTask

  describe "async/1" do
    setup do
      response = %{"type" => "response", "payload" => 2}
      redis_message = {:redix_pubsub, :foo, :bar, :message, %{payload: Jason.encode!(response)}}

      %{response: response, redis_message: redis_message}
    end

    test "spawns a task" do
      assert SyncTask.async("foo_event", "foo_channel", 1000).__struct__ == Task
    end

    test "it returns a payload if a :message event is delivered to it", %{
      response: response,
      redis_message: redis_message
    } do
      me = self()

      Task.start(fn ->
        # NOTE: We need to spawn the task inside the same process that awaits on the response
        # This is a limitation of the Task module, not a problem for our current implementation
        # but something to take into account for testing
        task = SyncTask.async("foo_event", "foo_channel", 1000)
        send(me, {:task_pid, task.pid})
        {:ok, payload} = task |> Task.await()

        send(me, {:received, payload})
      end)

      assert_receive {:task_pid, pid}, 1_000
      send(pid, redis_message)

      assert_receive {:received, ^response}, 1_000
    end

    test "it keeps listening if other kind of event is delivered to it", %{
      response: response,
      redis_message: redis_message2
    } do
      me = self()
      redis_message1 = {:redix_pubsub, :foo, :bar, :message, %{payload: Jason.encode!(%{a: 1})}}

      Task.start(fn ->
        task = SyncTask.async("foo_event", "foo_channel", 1000)
        send(me, {:task_pid, task.pid})
        {:ok, payload} = task |> Task.await()

        send(me, {:received, payload})
      end)

      assert_receive {:task_pid, pid}, 1_000
      send(pid, redis_message1)
      send(pid, redis_message2)

      assert_receive {:received, ^response}, 1_000
    end

    test "it stops if the connection goes down" do
      me = self()
      down_message = {:DOWN, :foo, :bar, :baz, "because"}

      Task.start(fn ->
        task = SyncTask.async("foo_event", "foo_channel", 1000)
        send(me, {:task_pid, task.pid})
        {:error, reason} = task |> Task.await()

        send(me, {:received, reason})
      end)

      assert_receive {:task_pid, pid}, 1_000
      send(pid, down_message)

      assert_receive {:received, "because"}, 1_000
    end

    test "it returns an error if it times out" do
      me = self()

      Task.start(fn ->
        task = SyncTask.async("foo_event", "foo_channel", 100)
        {:error, reason} = task |> Task.await()

        send(me, {:received, reason})
      end)

      assert_receive {:received, :timeout}, 1_000
    end
  end
end
