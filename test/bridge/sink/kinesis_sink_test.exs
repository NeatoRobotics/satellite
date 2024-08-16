defmodule Satellite.Bridge.Sink.KinesisTest do
  use ExUnit.Case
  alias Satellite.Bridge.Sink.Kinesis
  alias Ecto.UUID

  import ExUnit.CaptureLog
  import Mock

  describe "send/2" do
    setup do
      message = %Broadway.Message{
        acknowledger: nil,
        data: Jason.encode!(2),
        metadata: %{stream_name: "foo"}
      }

      sink_opts = %{
        kinesis_role_arn: UUID.generate(),
        assume_role_region: "eu-west-1"
      }

      %{message: message, sink_opts: sink_opts}
    end

    test "missing parameters", %{message: message} do
      {result, log} =
        with_log(fn ->
          Kinesis.send([message], %{})
        end)

      assert log =~ "Missing kinesis configuration parameters"
      assert result == :ok
    end

    test "failing to assume role", %{message: message, sink_opts: sink_opts} do
      with_mock ExAws, [:passthrough],
        request: fn _ ->
          {:error, "not allowed"}
        end do
        {result, log} =
          with_log(fn ->
            Kinesis.send([message], sink_opts)
          end)

        assert log =~ "failed to assume role"
        assert result == :ok
      end
    end

    test "successfully sending message", %{message: message, sink_opts: sink_opts} do
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
        request: fn _, _ -> {:ok, :ok} end do
        {result, log} =
          with_log(fn ->
            Kinesis.send([message], sink_opts)
          end)

        assert_called_exactly(ExAws.request(:_), 1)
        assert_called_exactly(ExAws.request(:_, :_), 1)

        assert log =~ "batch of messages were successfully sent to kinesis"
        assert result == :ok
      end
    end
  end
end
