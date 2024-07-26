defmodule Satellite.Behaviour do
  @moduledoc """
  A behaviour to implement event sending.
  """

  @callback send(Satellite.Event.t()) :: :ok | {:error, term()}
end
