defmodule SatelliteTest do
  use ExUnit.Case
  doctest Satellite

  describe "process_data/1" do
    setup do
      services = Satellite.services()

      on_exit(fn ->
        Application.put_env(:satellite, :bridge, %{services: services})
      end)
    end

    test "with happy path" do
      Application.put_env(:satellite, :bridge, %{services: [Double, Double, Double]})

      data = 2 |> Jason.encode!()

      assert Satellite.process_data(data) == {:ok, 16}
    end

    test "with failed path" do
      Application.put_env(:satellite, :bridge, %{services: [Double, Fail, Double]})

      data = 2 |> Jason.encode!()

      assert Satellite.process_data(data) == {:error, "Service error"}
    end
  end

  describe "handle_message/3" do
    setup do
      services = Satellite.services()
      message = %Broadway.Message{acknowledger: nil, data: Jason.encode!(2)}

      on_exit(fn ->
        Application.put_env(:satellite, :services, services)
      end)

      %{message: message}
    end

    test "it updates the message data if processing is correct", %{message: message} do
      Application.put_env(:satellite, :bridge, %{services: [Double, Double, Double]})

      message = Satellite.handle_message(nil, message, nil)

      assert message.data == "16"
      assert message.status == :ok
    end

    test "it fails the message if processing is incorrect", %{message: message} do
      Application.put_env(:satellite, :bridge, %{services: [Double, Fail, Double]})

      message = Satellite.handle_message(nil, message, nil)

      assert message.data == "2"
      assert message.status == {:failed, "Service error"}
    end
  end
end
