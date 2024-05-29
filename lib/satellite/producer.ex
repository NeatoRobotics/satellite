defmodule Satellite.Producer do
  @moduledoc """
  A generic behaviour to implement a Satellite Producer.

  This module defines callbacks to normalize options and send event to any message queue system.
  """

  @callback send(
              entity_type :: String.t(),
              entity_id :: String.t(),
              event_type :: String.t(),
              payload :: map(),
              producer_opts :: map()
            ) :: :ok | {:error, term()}
  @callback send(event_type :: String.t(), payload :: map(), producer_opts :: map()) ::
              :ok | {:error, term()}
end
