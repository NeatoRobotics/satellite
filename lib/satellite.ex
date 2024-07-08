defmodule Satellite do
  alias Satellite.Event

  @spec send(Event.t()) :: :ok | {:error, term()}
  def send(%Event{} = event) do
    {handler, handler_opts} = Application.fetch_env!(:satellite, :handler)
    handler.send(event, handler_opts)
  end
end
