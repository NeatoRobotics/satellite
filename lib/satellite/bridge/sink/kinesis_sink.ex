defmodule Satellite.Bridge.Sink.Kinesis do
  @behaviour Satellite.Bridge.Sink.Behaviour

  require Logger

  @impl true
  def send(
        broadway_messages,
        %{
          kinesis_role_arn: kinesis_role_arn,
          assume_role_region: assume_role_region
        }
      )
      when is_list(broadway_messages) do
    stream_name =
      (broadway_messages |> hd()).metadata.stream_name ||
        raise "Kinesis stream ALWAYS needs a stream_name in the metadata"

    Logger.info("#{__MODULE__} sending a batch of events to Amazon Kinesis stream #{stream_name}")

    records = Enum.map(broadway_messages, &%{data: &1.data, partition_key: Ecto.ULID.generate()})

    # NOTE: we might move the write specifics to a support module
    # FIXME: Store the creds and are not expired reuse them instead of calling AWS to get requests every time
    with {:ok, %{body: body}} <-
           kinesis_role_arn
           |> ExAws.STS.assume_role(UUID.uuid4())
           |> ExAws.request() do
      Logger.debug("sending batch of events to kinesis")

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
          # NOTE: Should we be raising or failing the message?
          Logger.error("failed sending batch of messages to kinesis", reason: error)
      end
    else
      {:error, error} ->
        # NOTE: Should we be raising or failing the message?
        Logger.error("failed to assume role", reason: error)

      error ->
        # NOTE: Should we be raising or failing the message?
        Logger.error("failed to assume role", reason: error)
    end
  end

  @impl true
  def send(_broadway_messages, opts) do
    # NOTE: Should we be raising or failing the message?
    Logger.error("Missing kinesis configuration parameters", opts: opts)
  end
end
