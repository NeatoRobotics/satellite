defmodule Satellite.Event do
  @derive Jason.Encoder
  defstruct [:id, :origin, :timestamp, :version, :type, :payload]

  # TODO make validation for this
  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          origin: binary(),
          timestamp: DateTime.t(),
          version: integer(),
          type: binary(),
          payload: map()
        }

  def new(payload, envelope \\ %{}) do
    id = Map.get(envelope, :id) || Ecto.UUID.generate()
    origin = Map.get(envelope, :origin) || Application.fetch_env!(:satellite, :origin)
    timestamp = Map.get(envelope, :timestamp) || DateTime.utc_now()
    timestamp = DateTime.to_string(timestamp)

    %Satellite.Com.Vorwerk.Cleaning.Orbital.V1.Event{
      id: id,
      origin: origin,
      timestamp: timestamp,
      payload: payload
    }
  end
end
