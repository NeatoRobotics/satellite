defmodule Satellite do
  use Broadway
  use OK.Pipe

  require Logger

  alias Broadway.Message

  @allowed_producer_list [
    Satellite.RedisProducer,
    Satellite.KinesisProducer,
    Satellite.SQSProducer
  ]

  def start_link(_config) do
    bridge_opts = Application.get_env(:satellite, :bridge)

    if is_nil(bridge_opts) or Enum.empty?(bridge_opts) do
      raise(
        ArgumentError,
        """
        In order to start satellite, provide the bridge configurations.

        config :satellite,
          bridge: [
            producer: {...}
            consumer: {...}
          ]
        """
      )
    end

    {producer, _producer_opts} =
      producer_with_opts = Application.fetch_env!(:satellite, :bridge)[:producer]

    _enabled = Application.fetch_env!(:satellite, :enabled)
    _origin = Application.fetch_env!(:satellite, :origin)

    if producer not in @allowed_producer_list,
      do:
        raise(ArgumentError, """
        invalid producer given.
        Only the following producers are supported: #{Enum.map(@allowed_producer_list, &(" " <> inspect(&1)))}
        """)

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      context: %{
        producer: producer_with_opts
      },
      producer: [
        module: Application.fetch_env!(:satellite, :bridge)[:consumer]
      ],
      processors: [
        default: [
          concurrency: Application.fetch_env!(:satellite, :bridge)[:processors_concurrency]
        ]
      ],
      batchers: [
        default: batchers_config()
      ]
    )
  end

  @spec handle_message(atom(), Broadway.Message.t(), term()) :: Broadway.Message.t()
  def handle_message(_processor_name, message, _context) do
    Logger.info("#{__MODULE__} handling message #{inspect(message)}")

    case process_data(message.data) do
      {:ok, data} ->
        %{message | data: data |> Jason.encode!()}

      {:error, error} ->
        Logger.error(error)
        Message.failed(message, error)
    end
  end

  @spec process_data(term()) :: {:ok, term()} | {:error, term()}
  def process_data(data) do
    # FIXME: Should we decode here? Or should this happen at the boundary of the app?
    data = Jason.decode!(data)

    services()
    |> Enum.reduce({:ok, data}, fn service, acc ->
      acc ~>> apply_service(service)
    end)
  end

  def handle_batch(_default, msgs, _, %{producer: {producer, producer_opts}}) do
    Logger.info("#{__MODULE__}.handle_batch/3 called with #{length(msgs)} message(s)")

    enabled? = Map.get(producer_opts, :enabled?, true)

    if enabled? do
      producer.send(msgs, producer_opts)
    else
      Logger.info("Skipping handle_batch as producer is disabled")
    end

    msgs
  end

  def send(event) do
    {producer, producer_opts} = Application.fetch_env!(:satellite, :producer)
    producer.send(event, producer_opts)
  end

  def services do
    Application.fetch_env!(:satellite, :bridge)[:services]
  end

  defp batchers_config do
    Application.fetch_env!(:satellite, :bridge)[:batchers]
  end

  defp apply_service(x, service) do
    apply(service, :process, [x])
  end
end
