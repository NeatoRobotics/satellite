defmodule Satellite do
  alias Satellite.Event

  @behaviour Satellite.Behaviour

  @impl true
  def send(%Satellite.Com.Vorwerk.Cleaning.Orbital.V1.Event{} = event) do
    {handler, handler_opts} = Application.fetch_env!(:satellite, :handler)
    handler.send(event, handler_opts)
  end
end
