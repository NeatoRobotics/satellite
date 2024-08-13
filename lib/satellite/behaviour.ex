defmodule Satellite.Behaviour do
  @moduledoc """
  A behaviour to implement event sending.
  """

  alias Satellite.Com.Vorwerk.Cleaning.Orbital.V1
  
  @callback send(V1.Event.t()) :: :ok | {:error, term()}
end
