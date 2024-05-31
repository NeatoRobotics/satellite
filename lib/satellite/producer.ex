defmodule Satellite.Producer do
  @moduledoc """
  A generic behaviour to implement a Satellite Producer.

  This module defines callbacks to normalize options and send event to any message queue system.
  """

  alias Broadway.Message

  @type event :: %{
          required(:event_type) => String.t(),
          required(:payload) => map(),
          optional(:entity_type) => String.t(),
          optional(:entity_id) => String.t()
        }

  @callback send(Message.t() | [Message.t()], producer_opts :: map()) :: :ok | {:error, term()}
end
