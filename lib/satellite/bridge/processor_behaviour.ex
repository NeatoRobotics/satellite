defmodule Satellite.Bridge.ProcessorBehaviour do
  @moduledoc """
  A behaviour to implement data transformation after message ingestion

  This sits between source data ingestion and message output
  Source -> [Transformations] -> Sink
  """

  @callback process(term) ::
              {:ok, event :: term()}
              | {:ok, event :: term(), metadata :: map()}
              | {:error, :atom}
end
