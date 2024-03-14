defmodule Satellite.Message do
  @type t :: map()

  def new(entity_type, entity_id, event_type, payload) do
    %{
      origin: origin(),
      timestamp: DateTime.utc_now(),
      version: 1,
      entity_type: entity_type,
      entity_id: entity_id,
      event_type: event_type,
      payload: payload
    }
  end

  def new(event_type, payload) do
    %{
      origin: origin(),
      timestamp: DateTime.utc_now(),
      version: 1,
      entity_type: "unknown",
      entity_id: nil,
      event_type: event_type,
      payload: payload
    }
  end

  defp origin do
    Application.fetch_env!(:satellite, :origin)
  end
end
