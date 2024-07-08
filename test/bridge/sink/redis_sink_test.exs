defmodule Satellite.Bridge.Sink.RedisTest do
  use ExUnit.Case
  alias Satellite.Bridge.Sink.Redis

  import ExUnit.CaptureLog
  import Mock

  describe "send/2" do
    setup do
      message = %Broadway.Message{acknowledger: nil, data: Jason.encode!(2)}

      %{message: message}
    end

    test "missing parameters", %{message: message} do
      {result, log} =
        with_log(fn ->
          Redis.send([message], %{})
        end)

      assert log =~ "Missing redis configuration parameters"
      assert result == {:error, "Missing redis configuration parameters"}
    end

    test "failing to send message", %{message: message} do
      with_mock Redix, [:passthrough],
        command: fn _, _ ->
          {:error, "error"}
        end do
        {result, log} =
          with_log(fn ->
            Redis.send([message], %{channel_out: "foo"})
          end)

        assert log =~ "failed to publish broadcast due to closed redis connection"
        assert result == {:error, "error"}
      end
    end

    test "successfully sending message", %{message: message} do
      with_mock Redix, [:passthrough],
        command: fn _, _ ->
          {:ok, "foo"}
        end do
        {result, log} =
          with_log(fn ->
            Redis.send([message], %{channel_out: "foo"})
          end)

        assert_called_exactly(Redix.command(:_, :_), 1)

        assert log =~ ""
        assert result == :ok
      end
    end
  end
end
