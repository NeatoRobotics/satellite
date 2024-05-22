defmodule Satellite.SQSProducer do
  @behaviour Satellite.Producer

  require Logger

  @spec init(opts :: map()) :: {:ok, map()} | {:reconnect, map()} | {:error, String.t()}
  def init(opts) do
    Logger.info("starting producer #{__MODULE__}...")
    Logger.metadata(opts)

    with {:ok, _sqs_queue_url} <- validate(opts, :sqs_queue_url),
         {:ok, _sqs_message_retries_max_attempts} <-
           validate(opts, :sqs_message_retries_max_attempts),
         {:ok, _sqs_message_retries_base_backoff_in_ms} <-
           validate(opts, :sqs_message_retries_base_backoff_in_ms),
         {:ok, _sqs_message_retries_max_backoff_in_ms} <-
           validate(opts, :sqs_message_retries_max_backoff_in_ms) do
      establish_connection(opts)
    end
  end

  @impl true
  def establish_connection(opts) do
    # you don't need to have a process connected to an instance of SQS beforehand to interact with SQS
    sqs_opts = %{
      queue_url: opts.sqs_queue_url,
      retries_config: %{
        max_attempts: opts.sqs_message_retries_max_attempts,
        base_backoff_in_ms: opts.sqs_message_retries_base_backoff_in_ms,
        max_backoff_in_ms: opts.sqs_message_retries_max_backoff_in_ms
      }
    }

    {:ok, sqs_opts}
  end

  @impl true
  def send(entity_type, entity_id, event_type, payload, opts) do
    Logger.info(
      "sending event #{event_type} to Amazon SQS queue #{opts.queue_url}",
      payload: payload
    )

    message = Satellite.Message.new(entity_type, entity_id, event_type, payload)

    sqs_config = [retries: opts.retries_config]
    message_group_id = "#{entity_type}:#{entity_id}:#{event_type}"

    opts
    |> Map.fetch!(:queue_url)
    |> ExAws.SQS.send_message(Jason.encode!(message), message_group_id: message_group_id)
    |> ExAws.request(sqs_config)
  end

  @impl true
  def send(event_type, payload, opts) do
    Logger.info(
      "sending event #{event_type} to Amazon SQS queue #{opts.queue_url}",
      payload: payload
    )

    message = Satellite.Message.new(event_type, payload)

    sqs_config = [retries: opts.retries_config]
    message_group_id = "global:#{event_type}"

    opts
    |> Map.fetch!(:queue_url)
    |> ExAws.SQS.send_message(Jason.encode!(message), message_group_id: message_group_id)
    |> ExAws.request(sqs_config)
  end

  defp validate(opts, key, default \\ nil) when is_map(opts) do
    validate_option(key, opts[key] || default)
  end

  defp validate_option(field, nil),
    do: validation_error(field, "non empty value", nil)

  defp validate_option(:sqs_queue_url, value) when not is_binary(value) or value == "",
    do: validation_error(:sqs_queue_url, "a non empty string", value)

  defp validate_option(:sqs_message_retries_max_attempts, value) when not is_integer(value),
    do: validation_error(:sqs_message_retries_max_attempts, "a integer", value)

  defp validate_option(:sqs_message_retries_base_backoff_in_ms, value) when not is_integer(value),
    do: validation_error(:sqs_message_retries_base_backoff_in_ms, "a integer", value)

  defp validate_option(:sqs_message_retries_max_backoff_in_ms, value) when not is_integer(value),
    do: validation_error(:sqs_message_retries_max_backoff_in_ms, "a integer", value)

  defp validate_option(_, value), do: {:ok, value}

  defp validation_error(key, expected_value, current_value) do
    {:error, "expected #{inspect(key)} to be #{expected_value}, got: #{inspect(current_value)}"}
  end
end
