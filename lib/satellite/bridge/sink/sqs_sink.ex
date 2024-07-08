defmodule Satellite.Bridge.Sink.SQS do
  @behaviour Satellite.Bridge.Sink.Behaviour

  require Logger

  @impl true
  def send(broadway_messages, retries: retries, queue_url: queue_url)
      when is_list(broadway_messages) do
    Logger.info("#{__MODULE__} sending a batch of events to Amazon SQS queue")

    sqs_messages =
      Enum.map(broadway_messages, fn message ->
        identifier = UUID.uuid4()
        [id: identifier, message_body: Jason.encode!(message.data), message_group_id: identifier]
      end)

    queue_url
    |> ExAws.SQS.send_message_batch(sqs_messages)
    |> ExAws.request(retries: retries)
    |> case do
      {:ok, response} ->
        Logger.info("batch of messages were successfully sent to sqs", response: response)
        :ok

      {:error, error_msg} = error ->
        Logger.error("failed sending batch of messages to sqs", reason: error_msg)
        error
    end
  end

  @impl true
  def send(_broadway_messages, opts) do
    # NOTE: Should we be raising or failing the message?
    Logger.error("Missing SQS configuration parameters", opts: opts)
  end
end
