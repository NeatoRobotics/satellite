defmodule Satellite.Bridge do
  use Broadway
  use OK.Pipe

  alias Broadway.Message

  # FIXME: Maybe we should take it out to let the apps that use Satellite to define their own sinks
  @allowed_sink_list [
    Satellite.Bridge.Sink.Redis,
    Satellite.Bridge.Sink.SQS,
    Satellite.Bridge.Sink.Kinesis
  ]

  require Logger

  def start_link(
        sink: {sink, sink_opts},
        source: {source, source_opts},
        processors_concurrency: concurrency,
        batchers_config: batchers_config
      ) do
    if sink not in @allowed_sink_list,
      do:
        raise(ArgumentError, """
        invalid sink given.
        Only the following sinks are supported: #{Enum.map(@allowed_sink_list, &(" " <> inspect(&1)))}
        """)

    avro_client = Application.get_env(:satellite, :avro_client)

    if !avro_client and (sink_opts[:format] == :avro || source_opts[:format] == :avro),
      do:
        raise(ArgumentError, """
        if `format` is avro for sink and/or source, an `avro_client` must be provided and instantiated.
        """)

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      context: %{
        avro_client: avro_client,
        sink: %{module: sink, opts: sink_opts |> Enum.into(%{})},
        source: %{module: source, opts: source_opts |> Enum.into(%{})}
      },
      producer: [
        module: {source, source_opts},
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: concurrency
        ]
      ],
      batchers: [
        default: batchers_config
      ]
    )
  end

  @impl true
  def handle_message(_processor_name, message, context) do
    message_str = "#{inspect(message)}"

    Logger.info("#{__MODULE__} handling message", event: message_str)

    # FIXME: review the clauses / batch mechanism completely
    case process_data(message.data, __MODULE__.services(), context) do
      {:ok, %{data: data, metadata: %{event_type: event_type} = metadata}} ->
        %{message | data: data, metadata: metadata}
        |> Message.put_batch_key(event_type)

      {:ok, %{data: data, metadata: metadata}} ->
        %{message | data: data, metadata: metadata}

      {:error, error} ->
        Logger.error("#{__MODULE__} failed processing message",
          event: message_str,
          reason: error
        )

        Message.failed(message, error)
    end
  end

  @spec process_data(term(), [any], map()) :: {:ok, map()} | {:error, term()}
  def process_data(data, services, context) do
    decode_data(data, context)
    |> OK.flat_map(fn data ->
      # FIXME: do this better. We will only use Satellite Events so the decoding should perform
      # validation and allow us to get the type straight away
      type = get_event_type(data)

      metadata =
        if type do
          %{event_type: type}
        else
          %{}
        end

      Enum.reduce(services, {:ok, %{data: data, metadata: metadata}}, fn service, acc ->
        acc
        ~>> apply_service(service)
        ~> merge_metadata(acc)
      end)
      ~>> encode_data(context)
    end)
  end

  @impl true
  def handle_batch(_default, msgs, _, %{sink: %{module: sink, opts: opts}}) do
    Logger.info("#{__MODULE__}.handle_batch/3 called with #{length(msgs)} message(s)")

    sink.send(msgs, opts)

    msgs
  end

  def child_spec(_opts) do
    if Application.get_env(:satellite, :bridge) && Application.get_env(:satellite, :bridge) != [] do
      %{
        id: __MODULE__,
        start: {__MODULE__, :start_link, [get_bridge_opts()]}
      }
    else
      nil
    end
  end

  defp get_bridge_opts do
    {sink, sink_opts} = Application.fetch_env!(:satellite, :bridge)[:sink]
    batchers_config = Application.fetch_env!(:satellite, :bridge)[:batchers]
    {source, source_opts} = Application.fetch_env!(:satellite, :bridge)[:source]
    concurrency = Application.fetch_env!(:satellite, :bridge)[:processors_concurrency]

    [
      sink: {sink, sink_opts},
      source: {source, source_opts},
      processors_concurrency: concurrency,
      batchers_config: batchers_config
    ]
  end

  def services do
    Application.fetch_env!(:satellite, :bridge)[:services]
  end

  defp merge_metadata(%{data: data, metadata: metadata}, acc) do
    {:ok, %{metadata: metadata_acc}} = acc

    %{data: data, metadata: Map.merge(metadata_acc, metadata)}
  end

  defp merge_metadata(%{data: data}, acc) do
    {:ok, %{metadata: metadata_acc}} = acc

    %{data: data, metadata: metadata_acc}
  end

  defp apply_service(%{data: data}, service) do
    apply(service, :process, [data])
    |> case do
      {:ok, event} ->
        {:ok, %{data: event}}

      {:ok, event, metadata} ->
        {:ok, %{data: event, metadata: metadata}}

      error ->
        error
    end
  end

  defp get_event_type(%{type: type}) do
    type
  end

  defp get_event_type(%{"type" => type}) do
    type
  end

  defp get_event_type(_), do: nil

  @spec decode_data(String.t(), map()) :: {:ok, map()} | {:error, term()}
  defp decode_data(data, %{source: %{opts: %{format: :json}}}) do
    Jason.decode(data)
  end

  defp decode_data(data, %{avro_client: client, source: %{opts: %{format: :avro}}}) do
    # FIXME: seems like ocf format wraps the event in a list, for some reason,
    # so we either unwrap it (and we are assuming ofc format here..)
    # or we figure out a cleaner and more clever way of guessing the schemas
    # or we just go with plain format
    client.decode(data)
    |> case do
      {:ok, [decoded_event]} ->
        {:ok, decoded_event}

      any ->
        any
    end
  end

  @spec encode_data(map(), map()) :: {:ok, map()} | {:error, term()}
  defp encode_data(%{data: data, metadata: metadata}, %{sink: %{opts: %{format: :json}}}) do
    Jason.encode(data)
    |> OK.map(fn encoded_data ->
      %{data: encoded_data, metadata: metadata}
    end)
  end

  defp encode_data(%{data: data, metadata: %{schema_name: schema_name} = metadata}, %{
         avro_client: client,
         sink: %{opts: %{format: :avro}}
       }) do
    client.encode(data, schema_name: schema_name)
    |> OK.map(fn encoded_data ->
      %{data: encoded_data, metadata: metadata}
    end)
  end
end
