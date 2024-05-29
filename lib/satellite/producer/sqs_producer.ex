defmodule Satellite.SQSProducer do
  @behaviour Satellite.Producer

  require Logger

  @impl true
  def send(entity_type, entity_id, event_type, payload, opts) do
    Logger.info(
      "sending event #{event_type} to Amazon SQS queue #{opts.queue_url}",
      payload: payload
    )

    message = Satellite.Message.new(entity_type, entity_id, event_type, payload)

    sqs_config = [retries: opts.retries]
    message_group_id = "#{entity_type}:#{entity_id}:#{event_type}"

    opts
    |> Map.fetch!(:queue_url)
    |> ExAws.SQS.send_message(Jason.encode!(message), message_group_id: message_group_id)
    |> ExAws.request(sqs_config)
  end

  @impl true
  def send(event_type, payload, opts) do
    Logger.info(
      "#{__MODULE__} sending event #{event_type} to Amazon SQS queue #{opts.queue_url}",
      payload: payload
    )

    message = Satellite.Message.new(event_type, payload)

    sqs_config = [retries: opts.retries]
    message_group_id = "global:#{event_type}"

    opts
    |> Map.fetch!(:queue_url)
    |> ExAws.SQS.send_message(Jason.encode!(message), message_group_id: message_group_id)
    |> ExAws.request(sqs_config)
  end
end
