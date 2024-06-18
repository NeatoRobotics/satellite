defmodule Satellite.Event do
  @derive Jason.Encoder
  defstruct [:origin, :timestamp, :version, :event_type, :payload]

  @type t :: %{
          origin: binary(),
          timestamp: binary(),
          version: integer(),
          event_type: binary(),
          payload: map()
        }
end
