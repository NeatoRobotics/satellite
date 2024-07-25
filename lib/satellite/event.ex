defmodule Satellite.Event do
  @derive Jason.Encoder
  defstruct [:id, :origin, :timestamp, :version, :type, :payload]

  # TODO make validation for this
  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          origin: binary(),
          timestamp: binary(),
          version: integer(),
          type: binary(),
          payload: map()
        }

  def new(attrs) do
    id = Map.get(attrs, :id) || Ecto.UUID.generate()
    origin = Map.get(attrs, :origin) || Application.fetch_env!(:satellite, :origin)
    timestamp = Map.get(attrs, :timestamp) || DateTime.utc_now()

    default_values = %{id: id, origin: origin, timestamp: timestamp, version: 1}

    struct!(__MODULE__, default_values |> Map.merge(attrs))
  end
end
