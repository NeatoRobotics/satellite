defmodule Satellite.Event do
  @derive Jason.Encoder
  defstruct [:origin, :timestamp, :version, :type, :context, :payload]

  # TODO make validation for this
  @type t :: %__MODULE__{
          origin: binary(),
          timestamp: binary(),
          version: integer(),
          type: binary(),
          context: map(),
          payload: map()
        }

  def new(attrs) do
    origin = Map.get(attrs, :origin) || Application.fetch_env!(:satellite, :origin)
    timestamp = Map.get(attrs, :timestamp) || DateTime.utc_now()

    default_values = %{origin: origin, timestamp: timestamp, version: 1}

    struct!(__MODULE__, default_values |> Map.merge(attrs))
  end
end
