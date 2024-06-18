defmodule Satellite.Producer do
  @moduledoc """
  A generic behaviour to implement a Satellite Producer.

  This module defines callbacks to normalize options and send event to any message queue system.
  """

  alias Broadway.Message
  alias Satellite.Event

  @callback send(Message.t() | [Message.t()] | Event.t(), producer_opts :: map()) ::
              :ok | {:error, term()}
end
