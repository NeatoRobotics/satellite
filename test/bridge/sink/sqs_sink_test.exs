defmodule Satellite.Bridge.Sink.SQSTest do
  use ExUnit.Case
  alias Satellite.Bridge.Sink.SQS

  import ExUnit.CaptureLog
  import Mock

  describe "send/2" do
    setup do
      message = %Broadway.Message{acknowledger: nil, data: %{a: 2}}

      sink_opts = [
        aws_config: [
          :sqs,
          region: "eu-central-1",
          host: "sqs.eu-central-1.amazonaws.com",
          retries: %{
            max_attempts: 2,
            base_backoff_in_ms: 10,
            max_backoff_in_ms: 10_000
          }
        ],
        queue_url: "foo_url"
      ]

      %{message: message, sink_opts: sink_opts}
    end

    test "missing parameters", %{message: message} do
      {result, log} =
        with_log(fn ->
          SQS.send([message], %{})
        end)

      assert log =~ "Missing SQS configuration parameters"
      assert result == :ok
    end

    test "failing to send message", %{message: message, sink_opts: sink_opts} do
      with_mock ExAws, [:passthrough],
        request: fn _, _ ->
          {:error, "error"}
        end do
        {result, log} =
          with_log(fn ->
            SQS.send([message], sink_opts)
          end)

        assert log =~ "failed sending batch of messages to sqs"
        assert result == {:error, "error"}
      end
    end

    test "successfully sending message", %{message: message, sink_opts: sink_opts} do
      with_mock ExAws, [:passthrough], request: fn _, _ -> {:ok, :ok} end do
        {result, log} =
          with_log(fn ->
            SQS.send([message], sink_opts)
          end)

        assert_called_exactly(ExAws.request(:_, :_), 1)

        assert log =~ "batch of messages were successfully sent to sqs"
        assert result == :ok
      end
    end
  end
end
