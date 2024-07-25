defmodule Satellite.BridgeTest do
  use ExUnit.Case, async: false

  alias Satellite.Bridge
  alias Satellite.Handler.Redis
  alias Ecto.UUID
  alias Satellite.Event

  import Mock

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
        event1 = %Event{type: "foo", origin: "robot", payload: %{a: 1}}
        RedisHandler.send(event1)

        assert_receive {:message, data}

        assert event1 |> Jason.encode!() |> Jason.decode!() ==
                 data |> Base.decode64!() |> Jason.decode!()
      end
    end
  end

  describe "process_data/1" do
    test "with happy path" do
      data = 2 |> Jason.encode!()

      assert Bridge.process_data(data, [Double, Double, Double]) == {:ok, "16"}
    end

    test "data not decodable" do
      data = "{2: AAAA}"

      assert {:error, %Jason.DecodeError{position: 1, token: nil, data: "{2: AAAA}"}} =
               Bridge.process_data(data, [Double, Double])
    end

    test "with failed path" do
      data = 2 |> Jason.encode!()

      assert Bridge.process_data(data, [Double, Fail, Double]) == {:error, "Service error"}
    end
  end

  describe "handle_message/3" do
    setup do
      message = %Broadway.Message{acknowledger: nil, data: Jason.encode!(2)}

      %{message: message}
    end

    test "it updates the message data if processing is correct", %{message: message} do
      with_mock Bridge, [:passthrough], services: fn -> [Double, Double, Double] end do
        message = Bridge.handle_message(nil, message, nil)

        assert message.data == "16"
        assert message.status == :ok
      end
    end

    test "it fails the message if processing is incorrect", %{message: message} do
      with_mock Bridge, [:passthrough], services: fn -> [Double, Fail, Double] end do
        message = Bridge.handle_message(nil, message, nil)

        assert message.data == "2"
        assert message.status == {:failed, "Service error"}
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
                 status: {:failed, %Jason.DecodeError{position: 1, token: nil, data: "{2: AAAA}"}}
               }
      end
    end
  end
end
