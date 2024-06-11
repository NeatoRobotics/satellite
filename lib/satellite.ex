defmodule Satellite do
  use Broadway

  require Logger

  alias Broadway.Message

  @allowed_producer_list [
    Satellite.RedisProducer,
    Satellite.KinesisProducer,
    Satellite.SQSProducer
  ]

  def start_link(_config) do
    {producer, _producer_opts} =
      producer_with_opts = Application.fetch_env!(:satellite, :producer)

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
        module: Application.fetch_env!(:satellite, :consumer)
      ],
      processors: [
        default: [concurrency: Application.fetch_env!(:satellite, :processors_concurrency)]
      ],
      batchers: [
        default: batchers_config()
      ]
    )
  end

  def handle_message(_processor_name, message, _context) do
    Logger.info("#{__MODULE__} handling message #{inspect(message)}")

    Message.update_data(message, &process_data/1)
  end

  def process_data(event) do
    event = Jason.decode!(event)

    Enum.reduce_while(services(), event, fn module, event ->
      case apply(module, :process, [event]) do
        {:ok, event} -> {:cont, event}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
    |> case do
      {:error, error} ->
        Logger.error(error)

      event ->
        event
    end
  end

  def handle_batch(_default, msgs, _, %{producer: {producer, producer_opts}}) do
    Logger.info("#{__MODULE__}.handle_batch/3 called with #{length(msgs)} messages")

    producer.send(msgs, producer_opts)

    msgs
  end

  defp services do
    Application.fetch_env!(:satellite, :services)
  end

  defp batchers_config do
    Application.fetch_env!(:satellite, :batchers)
  end
end
