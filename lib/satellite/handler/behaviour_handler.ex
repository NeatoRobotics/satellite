defmodule Satellite.Handler.Behaviour do
  @moduledoc """
  A generic behaviour to implement a Satellite Producer.

  This module defines callbacks to normalize options and send event to any message queue system.
  """

  alias Satellite.Com.Vorwerk.Cleaning.Orbital.V1

  @callback send(V1.Event.t(), opts :: Keyword.t()) :: :ok | {:error, term()}
end
