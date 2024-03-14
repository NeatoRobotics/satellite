defmodule Satellite do
  use GenServer

  require Logger

  @allowed_producer_list [Satellite.RedisProducer]
  @reconnect_after_ms 5_000

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(opts) do
    Logger.debug("starting #{__MODULE__}")
    Process.flag(:trap_exit, true)
    producer = Application.fetch_env!(:satellite, :producer)
    producer_opts = Application.fetch_env!(:satellite, :producer_opts)
    _enabled = Application.fetch_env!(:satellite, :enabled)
    _origin = Application.fetch_env!(:satellite, :origin)

    if producer not in @allowed_producer_list,
      do:
        raise(
          ArgumentError,
          "invalid options :producer given to #{inspect(__MODULE__)}.start_link/1 #{inspect(opts)}"
        )

    state = %{producer: producer, producer_opts: nil, reconnect_timer: nil}

    case producer.init(producer_opts) do
      {:error, message} ->
        Logger.error("invalid options given to #{inspect(producer)}.init/1")
        raise ArgumentError, "invalid options given to #{inspect(producer)}.init/1, " <> message

      {:ok, opts} ->
        {:ok, %{state | producer_opts: opts}}

      {:reconnect, opts} ->
        schedule_reconnect(%{state | producer_opts: opts})
    end
  end

  @impl true
  def handle_call(
        {:send, entity_type, entity_id, event_type, payload},
        _from,
        %{producer: producer, producer_opts: producer_opts} = state
      ) do
    response = producer.send(entity_type, entity_id, event_type, payload, producer_opts)

    {:reply, response, state}
  end

  @impl true
  def handle_call(
        {:send, event_type, payload},
        _from,
        %{producer: producer, producer_opts: producer_opts} = state
      ) do
    response = producer.send(event_type, payload, producer_opts)

    {:reply, response, state}
  end

  @impl true
  def handle_info(:establish_conn, %{producer: producer} = state) do
    {:noreply, producer.establish_connection(state)}
  end

  @impl true
  def handle_info(
        {:EXIT, producer_pid, reason},
        %{producer_pid: producer_pid, producer: producer} = state
      ) do
    Logger.info("#{__MODULE__} is exiting with reason #{inspect(reason)}")
    {:noreply, producer.establish_connection(state)}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info("#{__MODULE__} is terminating with reason #{inspect(reason)}")
    state
  end

  @spec send(String.t(), String.t(), String.t(), map()) :: :ok | {:error, term()}
  def send(entity_type, entity_id, event_type, payload) do
    if enabled?() do
      GenServer.call(__MODULE__, {:send, entity_type, entity_id, event_type, payload})
    else
      :ok
    end
  end

  @spec send(String.t(), map()) :: :ok | {:error, term()}
  def send(event_type, payload) do
    GenServer.call(__MODULE__, {:send, event_type, payload})
  end

  defp schedule_reconnect(%{reconnect_timer: timer}) do
    Logger.info("Attempting to reconnect in #{@reconnect_after_ms}...")

    timer && Process.cancel_timer(timer)
    Process.send_after(self(), :establish_conn, @reconnect_after_ms)
  end

  defp enabled? do
    Application.fetch_env!(:satellite, :enabled)
  end
end
