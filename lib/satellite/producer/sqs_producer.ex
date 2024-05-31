defmodule Satellite.SQSProducer do
  @behaviour Satellite.Producer

  require Logger

  alias Broadway.Message

  @impl true
  def send([message], opts), do: __MODULE__.send(message, opts)

  def send(broadway_messages, opts) when is_list(broadway_messages) do
    Logger.info("#{__MODULE__} sending a batch of events to Amazon SQS queue")

    sqs_messages =
      Enum.map(broadway_messages, fn message ->
        identifier = UUID.uuid4()
        [id: identifier, message_body: Jason.encode!(message.data), message_group_id: identifier]
      end)

    sqs_config = [retries: opts.retries]

    opts
    |> Map.fetch!(:queue_url)
    |> ExAws.SQS.send_message_batch(sqs_messages)
    |> ExAws.request(sqs_config)
  end

  def send(
        %Message{
          data: %{
            "entity_type" => entity_type,
            "entity_id" => entity_id,
            "event_type" => event_type,
            "payload" => payload
          }
        },
        opts
      )
      when not is_nil(entity_id) do
    Logger.info(
      "Sending event #{event_type} to Amazon SQS queue #{opts.queue_url}",
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
  def send(%Message{data: %{"event_type" => event_type, "payload" => payload}}, opts) do
    Logger.info(
      "Sending event #{event_type} to Amazon SQS queue #{opts.queue_url}",
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

  def send(event, _opts) do
    raise """
      #{__MODULE__} is unable to handle the event #{inspect(event)}
      The event is missing some required fields
    """
  end
end
