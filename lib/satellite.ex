defmodule Satellite do
  alias Satellite.Event

  @behaviour Satellite.Behaviour

  @impl true
  def send(%Event{} = event) do
    {handler, handler_opts} = Application.fetch_env!(:satellite, :handler)
    handler.send(event, handler_opts)
  end

  def send_sync(%Event{} = event) do
    # 1. subscribe to a channel "satellite:sync:pid"
    # 2. Wrap sending event in a task
    # 3. Away on the task for 5_000 expecting a response
    #   3.1 if response arrives in time, return {:ok, response}
    #   3.2 if response does not arrive in time, return {:error, timeout}
    # 4. Unsubscribe to channel
    # 5. Remove channel?
    send(event)
  end
end
