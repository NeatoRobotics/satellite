defmodule Satellite do
  use Broadway

  require Logger

  alias Broadway.Message

  @allowed_producer_list [Satellite.RedisProducer, Satellite.SQSProducer]

  def start_link(_config) do
    {producer, _producer_opts} = Application.fetch_env!(:satellite, :producer)
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
      producer: [
        module: consumer_with_opts()
      ],
      processors: [
        default: [concurrency: 1]
      ],
      batchers: [
        s3: [concurrency: 2, batch_size: 1, batch_timeout: 1000]
      ]
    )
  end

  def handle_message(_processor_name, message, _context) do
    Logger.info("#{__MODULE__} handling message #{inspect(message)}")

    message
    |> Message.update_data(&process_data/1)
    |> Message.put_batcher(:s3)
  end

  def process_data(event) do
    Enum.reduce_while(processors(), event, fn module, event ->
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

  def handle_batch(:s3, [message] = msgs, _, _) do
    {producer, producer_opts} = producer_with_opts()

    producer.send("error", message.data, producer_opts)

    msgs
  end

  defp consumer_with_opts do
    Application.fetch_env!(:satellite, :consumer)
  end

  defp producer_with_opts do
    Application.fetch_env!(:satellite, :producer)
  end

  defp processors do
    Application.fetch_env!(:satellite, :processors)
  end
end
