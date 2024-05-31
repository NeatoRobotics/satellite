defmodule Satellite.RedisProducer do
  @behaviour Satellite.Producer

  require Logger

  @spec init(opts :: map()) :: {:ok, map()} | {:reconnect, map()} | {:error, String.t()}
  def init(opts) do
    Logger.info("starting producer #{__MODULE__}...")
    Logger.metadata(opts)

    with {:ok, _host} <- validate(opts, :host),
         {:ok, _port} <- validate(opts, :port) do
      establish_connection(opts)
    end
  end

  def establish_connection(opts) do
    case Redix.start_link(host: opts.host, port: opts.port) do
      {:ok, producer_pid} ->
        Logger.info("successfully connected to redis server")
        {:ok, Map.put(opts, :producer_pid, producer_pid)}

      {:error, _} ->
        Logger.info("unable to establish initial redis connection")
        {:reconnect, Map.put(opts, :producer_pid, nil)}
    end
  end

  @impl true
  def send(
        %{
          "entity_type" => entity_type,
          "entity_id" => entity_id,
          "event_type" => event_type,
          "payload" => payload
        },
        %{producer_pid: redis_pid} = _opts
      ) do
    Logger.info(
      "sending event to channel #{entity_type}:#{entity_id}:#{event_type}",
      payload: payload
    )

    message = Satellite.Message.new(entity_type, entity_id, event_type, payload)

    case Redix.command(redis_pid, [
           "PUBLISH",
           "#{entity_type}:#{entity_id}:#{event_type}",
           Jason.encode!(message)
         ]) do
      {:ok, _} ->
        :ok

      {:error, %Redix.ConnectionError{reason: :closed} = error} ->
        Logger.info(
          "failed to publish broadcast due to closed redis connection: #{inspect(error)}"
        )

        {:error, :connection_closed}

      {:error, reason} ->
        Logger.info(
          "failed to publish broadcast due to closed redis connection: #{inspect(reason)}"
        )

        {:error, reason}
    end
  end

  @impl true
  def send(
        %{"event_type" => event_type, "payload" => payload},
        %{producer_pid: redis_pid} = _opts
      ) do
    Logger.info(
      "sending event to channel global:#{event_type}",
      payload: payload
    )

    message = Satellite.Message.new(event_type, payload)

    case Redix.command(redis_pid, ["PUBLISH", "global:#{event_type}", Jason.encode!(message)]) do
      {:ok, _} ->
        :ok

      {:error, %Redix.ConnectionError{reason: :closed} = error} ->
        Logger.info(
          "failed to publish broadcast due to closed redis connection: #{inspect(error)}"
        )

        {:error, :connection_closed}

      {:error, reason} ->
        Logger.info(
          "failed to publish broadcast due to closed redis connection: #{inspect(reason)}"
        )

        {:error, reason}
    end
  end

  def send(event, _opts) do
    raise """
      #{__MODULE__} is unable to handle the event #{inspect(event)}
      The event is missing some required fields
    """
  end

  defp validate(opts, key, default \\ nil) when is_map(opts) do
    validate_option(key, opts[key] || default)
  end

  defp validate_option(:host, nil),
    do: validation_error(:host, "a non empty string", nil)

  defp validate_option(:host, value) when not is_binary(value) or value == "",
    do: validation_error(:host, "a non empty string", value)

  defp validate_option(:port, value) when not is_integer(value) or value not in 1..65353,
    do: validation_error(:port, "a integer", value)

  defp validate_option(_, value), do: {:ok, value}

  defp validation_error(key, expected_value, current_value) do
    {:error, "expected #{inspect(key)} to be #{expected_value}, got: #{inspect(current_value)}"}
  end
end
