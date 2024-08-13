# FIXME: make this only available for tests
defmodule Satellite.Avro.Client do
  use Avrora.Client,
    otp_app: :satellite,
    schemas_path: "./priv/schemas"
end
