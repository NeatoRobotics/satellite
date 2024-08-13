defmodule Satellite.BridgeTest do
  use ExUnit.Case, async: false

  alias Ecto.UUID
  alias Satellite.Bridge
  alias Satellite.Handler
  alias Satellite.Event
  alias Satellite.Com.Vorwerk.Cleaning.Orbital.V1

  import Mock
  use OK.Pipe

  describe "Bridge" do
    test "source to sink" do
      me = self()

      with_mock ExAws, [:passthrough],
        request: fn
          %{params: %{"Action" => "AssumeRole"}} ->
            response = %{
              access_key_id: UUID.generate(),
              secret_access_key: UUID.generate(),
              session_token: UUID.generate()
            }

            {:ok, %{body: response}}
        end,
        request: fn %{data: %{"Records" => [%{"Data" => data}]}}, _ ->
          send(me, {:message, data})
          {:ok, :ok}
        end do
        event1 = Event.new(%V1.RobotNotification{message: "hello"}, %{origin: "robot"})
        Handler.Redis.send(event1)

        assert_receive {:message, data}

        {:ok, decoded} =
          data
          |> Base.decode64()
          ~>> Event.decode()

        assert event1 == decoded
      end
    end
  end

  describe "process_data/1" do
    test "with happy path" do
      {:ok, event} = payload(2)

      assert {:ok, %{data: encoded_data, metadata: %{}}} =
               Bridge.process_data(event, [Double, Double, Double])

      {:ok, %V1.Event{payload: %V1.Payload{content: %{"a" => 16}}}} =
        Event.decode(encoded_data)
    end

    test "with happy path and metadata" do
      {:ok, event} = payload(5)

      assert {:ok, %{data: encoded_data, metadata: %{foo: 5}}} =
               Bridge.process_data(event, [DoubleWithMetadata, Double, Double])

      {:ok, %V1.Event{payload: %V1.Payload{content: %{"a" => 40}}}} =
        Event.decode(encoded_data)
    end

    test "data not decodable" do
      data = "invalid avro data"

      assert {:error, :invalid_data} == Bridge.process_data(data, [Double, Double])
    end

    test "with failed path" do
      {:ok, event} = payload(2)

      assert Bridge.process_data(event, [Double, Fail, Double]) == {:error, :service_error}
    end

    test "metadata get's merged" do
      {:ok, event} = payload(5)

      assert {:ok, %{data: encoded_data, metadata: %{foo: 10}}} =
               Bridge.process_data(event, [Double, DoubleWithMetadata, Double])

      {:ok, %V1.Event{payload: %V1.Payload{content: %{"a" => 40}}}} =
        Event.decode(encoded_data)

      assert {:ok, %{data: encoded_data, metadata: %{foo: 20}}} =
               Bridge.process_data(event, [Double, Double, DoubleWithMetadata])

      {:ok, %V1.Event{payload: %V1.Payload{content: %{"a" => 40}}}} =
        Event.decode(encoded_data)

      assert {:ok, %{data: encoded_data, metadata: %{foo: 10, bar: 20}}} =
               Bridge.process_data(event, [Double, DoubleWithMetadata, TripleWithMetadata])

      {:ok, %V1.Event{payload: %V1.Payload{content: %{"a" => 60}}}} =
        Event.decode(encoded_data)
    end

    test "with mixed keys" do
      {:ok, event} =
        Event.new(%V1.Payload{content: %{foo: "bar"}}, %{origin: "orbital"})
        |> Event.encode()

      assert {:ok, %{data: encoded_data, metadata: %{}}} =
               Bridge.process_data(event, [IdentityProcessor])

      {:ok, %V1.Event{payload: %V1.Payload{content: %{"foo" => "bar"}}}} =
        Event.decode(encoded_data)
    end
  end

  describe "handle_message/3" do
    setup do
      {:ok, data} = payload(2)
      message = %Broadway.Message{acknowledger: nil, data: data}

      %{message: message}
    end

    test "it updates the message data if processing is correct", %{message: message} do
      with_mock Bridge, [:passthrough], services: fn -> [Double, Double, Double] end do
        message = Bridge.handle_message(nil, message, nil)
        {:ok, %V1.Event{payload: %V1.Payload{content: %{"a" => 16}}}} = Event.decode(message.data)

        assert message.status == :ok
      end
    end

    test "it fails the message if processing is incorrect", %{message: message} do
      with_mock Bridge, [:passthrough], services: fn -> [Double, Fail, Double] end do
        message = Bridge.handle_message(nil, message, nil)

        {:ok, %V1.Event{payload: %V1.Payload{content: %{"a" => 2}}}} = Event.decode(message.data)
        assert message.status == {:failed, :service_error}
      end
    end

    test "it fails the message if processing is incorrect because of non-decodable message" do
      with_mock Bridge, [:passthrough], services: fn -> [Double, Fail, Double] end do
        message = %Broadway.Message{acknowledger: nil, data: "{2: AAAA}"}

        message = Bridge.handle_message(nil, message, nil)

        assert message == %Broadway.Message{
                 data: "{2: AAAA}",
                 metadata: %{},
                 acknowledger: nil,
                 batcher: :default,
                 batch_key: :default,
                 batch_mode: :bulk,
                 status: {:failed, :invalid_data}
               }
      end
    end
  end

  def payload(x) do
    Event.new(%V1.Payload{content: %{a: x}}, %{origin: "orbital"})
    |> Event.encode()
  end
end
