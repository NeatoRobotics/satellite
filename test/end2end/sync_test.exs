defmodule Satellite.End2End.SyncTest do
  use ExUnit.Case

  alias Satellite.Event
  alias Satellite.Sync

  setup_all do
    TestEchoConsumer.start_link()

    :ok
  end

  describe "send/1" do
    setup do
      event1 = Event.new(%{type: "foo", payload: %{a: 1}})
      event2 = Event.new(%{type: "foo", payload: %{a: 2}})

      %{events: [event1, event2]}
    end

    test "single event sent", %{events: [event, _]} do
      {:ok, %{"type" => "response", "payload" => payload}} = Sync.send(event)

      assert payload == %{"a" => 1}
    end

    test "multiple events", %{events: [event1, event2]} do
      {:ok, %{"type" => "response", "payload" => %{"a" => 1}}} = Sync.send(event1)
      {:ok, %{"type" => "response", "payload" => %{"a" => 2}}} = Sync.send(event2)
    end

    test "interleaved events", %{events: [event1, event2]} do
      me = self()

      Task.start(fn ->
        {:ok, response1} = Sync.send(event1)
        send(me, {:response1, response1})
      end)

      Task.start(fn ->
        {:ok, response2} = Sync.send(event2)
        send(me, {:response2, response2})
      end)

      assert_receive {:response1, %{"payload" => %{"a" => 1}}}, 5_000
      assert_receive {:response2, %{"payload" => %{"a" => 2}}}, 5_000
    end

    test "interleaved repeated events (same event received twice)", %{events: [event1, event2]} do
      me = self()

      Task.start(fn ->
        {:ok, response1} = Sync.send(event1)
        send(me, {:response1, response1})
      end)

      Task.start(fn ->
        Sync.publish(event1)
      end)

      Task.start(fn ->
        {:ok, response2} = Sync.send(event2)
        send(me, {:response2, response2})
      end)

      assert_receive {:response1, %{"payload" => %{"a" => 1}}}, 1_000
      # We only receive one response
      refute_receive {:response1, %{"payload" => %{"a" => 1}}}, 1_000
      assert_receive {:response2, %{"payload" => %{"a" => 2}}}, 1_000
    end

    test "repeated events received in series", %{events: [event, _]} do
      {:ok, %{"type" => "response", "payload" => %{"a" => 1}}} = Sync.send(event)
      {:ok, %{"type" => "response", "payload" => %{"a" => 1}}} = Sync.send(event)
    end

    test "failed call" do
      event = Event.new(%{type: "fail", payload: %{a: 1}})

      {:ok, %{"type" => "response", "payload" => "error"}} = Sync.send(event)
    end

    test "timeout" do
      event = Event.new(%{type: "timeout", payload: %{a: 1}})

      {:error, :timeout} = Sync.send(event, 200)
    end

    test "multiple calls with error and timeout", %{events: [event1, event2]} do
      me = self()

      fail_event = Event.new(%{type: "fail", payload: %{a: 1}})
      timeout_event = Event.new(%{type: "timeout", payload: %{a: 1}})

      Task.start(fn ->
        {:ok, response1} = Sync.send(event1)
        send(me, {:response1, response1})
      end)

      Task.start(fn ->
        {:ok, response2} = Sync.send(event2)
        send(me, {:response2, response2})
      end)

      Task.start(fn ->
        {:ok, fail_response} = Sync.send(fail_event)
        send(me, {:fail_response, fail_response})
      end)

      Task.start(fn ->
        {:error, :timeout} = Sync.send(timeout_event, 200)
        send(me, :timeout_event)
      end)

      assert_receive {:response1, %{"payload" => %{"a" => 1}}}, 1_000
      assert_receive {:response2, %{"payload" => %{"a" => 2}}}, 1_000
      assert_receive {:fail_response, %{"payload" => "error"}}, 1_000
      assert_receive :timeout_event, 6_000
    end
  end
end
