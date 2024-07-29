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

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      context: %{
        sink: {sink, sink_opts}
      },
      producer: [
        module: {source, source_opts},
        concurrency: concurrency
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
  def handle_message(_processor_name, message, _context) do
    message_str = "#{inspect(message)}"

    Logger.info("#{__MODULE__} handling message", event: message_str)

    case process_data(message.data, __MODULE__.services()) do
      {:ok, data, extras} ->
        %{message | data: data, metadata: extras}

      {:error, error} ->
        Logger.error("#{__MODULE__} failed processing message",
          event: message_str,
          reason: error
        )

        Message.failed(message, error)
    end
  end

  @spec process_data(term(), [any]) :: {:ok, term(), map()} | {:error, term()}
  def process_data(data, services) do
    Jason.decode(data)
    |> case do
      {:ok, data} ->
        Enum.reduce(services, {:ok, %{data: data, metadata: %{}}}, fn service, acc ->
          acc
          ~>> apply_service(service)
          |> case do
            {:ok, %{data: data, metadata: metadata}} ->
              {:ok, %{metadata: metadata_acc}} = acc
              {:ok, %{data: data, metadata: Map.merge(metadata_acc, metadata)}}

            {:ok, data} ->
              {:ok, %{metadata: metadata_acc}} = acc
              {:ok, %{data: data, metadata: metadata_acc}}

            error ->
              error
          end
        end)
        |> case do
          {:ok, %{data: data, metadata: metadata}} ->
            {:ok, data |> Jason.encode!(), metadata}

          error ->
            error
        end

      error ->
        error
    end
  end

  @impl true
  def handle_batch(_default, msgs, _, %{sink: {sink, opts}}) do
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

  defp apply_service(%{data: data}, service) do
    apply(service, :process, [data])
  end
end
