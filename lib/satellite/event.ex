defmodule Satellite.Event do
  @derive Jason.Encoder
  defstruct [:id, :origin, :timestamp, :version, :type, :payload]

  alias Satellite.Com.Vorwerk.Cleaning.Orbital.V1
  alias Satellite.Avro.Client

  use OK.Pipe

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

  @spec encode(V1.Event.t()) :: {:ok, binary()} | {:error, term()}
  def encode(%V1.Event{} = event) do
    V1.Event.to_avro(event)
    ~>> Client.encode(schema_name: "com.vorwerk.cleaning.orbital.v1.Event")
  end

  @spec decode(binary()) :: {:ok, V1.Event.t()} | {:error, term()}
  def decode(data) do
    {:ok, [decoded]} = Client.decode(data)

    V1.Event.from_avro(decoded)
  end
end
