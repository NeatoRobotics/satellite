defmodule Satellite.KinesisProducer do
  @behaviour Satellite.Producer

  require Logger

  @impl true
  def send(broadway_messages, opts) when is_list(broadway_messages) do
    Logger.info("#{__MODULE__} sending a batch of events to Amazon Kinesis")

    kinesis_role_arn = opts.kinesis_role_arn

    records = Enum.map(broadway_messages, &%{data: &1.data, partition_key: Ecto.ULID.generate()})

    with {:ok, %{body: body}} <-
           kinesis_role_arn
           |> ExAws.STS.assume_role(UUID.uuid4())
           |> ExAws.request() do
      Logger.debug("sending batch of events to kinesis")
      stream_name = opts.kinesis_stream_name
      assume_role_region = opts.assume_role_region

      stream_name
      |> ExAws.Kinesis.put_records(records)
      |> ExAws.request(
        access_key_id: Map.fetch!(body, :access_key_id),
        secret_access_key: Map.fetch!(body, :secret_access_key),
        region: assume_role_region,
        security_token: Map.fetch!(body, :session_token),
        debug_requests: true
      )
      |> case do
        {:ok, response} ->
          Logger.info("batch of messages were successfully sent to kinesis", response: response)

        {:error, error} ->
          Logger.error("failed sending batch of messages to kinesis", reason: error)
      end
    else
      {:error, error} ->
        Logger.error("failed to assume role", reason: error)

      error ->
        Logger.error("failed to assume role", reason: error)
    end
  end

  def send(event, _opts) do
    raise """
      #{__MODULE__} is unable to handle the event #{inspect(event)}
      The event is missing some required fields or is not supported.
    """
  end
end
