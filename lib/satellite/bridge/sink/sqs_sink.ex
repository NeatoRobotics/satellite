defmodule Satellite.Bridge.Sink.SQS do
  @behaviour Satellite.Bridge.Sink.Behaviour

  require Logger

  @impl true
  def send(broadway_messages, aws_config: aws_config, queue_url: queue_url)
      when is_list(broadway_messages) do
    Logger.info("#{__MODULE__} sending a batch of events to Amazon SQS queue",
      aws_config: aws_config,
      queue_url: queue_url,
      # FIXME: remove this eventually!!
      messages: broadway_messages
    )

    sqs_messages =
      Enum.map(broadway_messages, fn %{data: event, metadata: metadata} ->
        message_id = Map.get(metadata, :message_id, UUID.uuid4())
        group_id = Map.get(metadata, :group_id, UUID.uuid4())
        [id: message_id, message_body: event, message_group_id: group_id]
      end)

    queue_url
    |> ExAws.SQS.send_message_batch(sqs_messages)
    |> ExAws.request(aws_config)
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
