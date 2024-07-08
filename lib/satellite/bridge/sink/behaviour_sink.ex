defmodule Satellite.Bridge.Sink.Behaviour do
  @moduledoc """
  A generic behaviour to implement a Satellite Producer.

  This module defines callbacks to normalize options and send event to any message queue system.
  """

  alias Broadway.Message

  @callback send([Message.t()], opts :: map()) :: :ok | {:error, term()}
end
