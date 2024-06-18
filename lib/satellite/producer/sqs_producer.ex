defmodule Satellite.SQSProducer do
  @behaviour Satellite.Producer

  require Logger

  alias Broadway.Message
  alias Satellite.Event

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
  def send(%Message{data: %{"event_type" => event_type, "origin" => origin} = event}, opts) do
    Logger.info(
      "Sending event #{event_type} to Amazon SQS queue #{opts.queue_url}",
      event: event
    )

    sqs_config = [retries: opts.retries]
    message_group_id = "#{origin}:#{event_type}"

    opts
    |> Map.fetch!(:queue_url)
    |> ExAws.SQS.send_message(Jason.encode!(event), message_group_id: message_group_id)
    |> ExAws.request(sqs_config)
    |> case do
      {:ok, response} ->
        Logger.info("Successfully sent a message to sqs", response: response)
        :ok

      {:error, error_msg} = error ->
        Logger.error("Failed to send  a message to sqs", reason: error_msg)
        error
    end
  end

  @impl true
  def send(%Event{event_type: event_type, origin: origin} = event, opts) do
    Logger.info(
      "Sending event #{event_type} from #{origin} to Amazon SQS queue #{opts.queue_url}",
      event
    )

    sqs_config = [retries: opts.retries]
    message_group_id = "#{origin}:#{event_type}"

    opts
    |> Map.fetch!(:queue_url)
    |> ExAws.SQS.send_message(Jason.encode!(event), message_group_id: message_group_id)
    |> ExAws.request(sqs_config)
    |> case do
      {:ok, response} ->
        Logger.info("Successfully sent a message to sqs", response: response)
        :ok

      {:error, error_msg} = error ->
        Logger.error("Failed to send a message to sqs", reason: error_msg)

        error
    end
  end

  def send(event, _opts) do
    raise """
      #{__MODULE__} is unable to handle the event #{inspect(event)}
      The event is missing some required fields
    """
  end
end
