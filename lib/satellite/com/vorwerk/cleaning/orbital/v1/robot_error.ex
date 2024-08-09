defmodule Satellite.Com.Vorwerk.Cleaning.Orbital.V1.RobotError do
  @moduledoc """
  DO NOT EDIT MANUALLY: This module was automatically generated from an AVRO schema.

  ### Description
  Errors received from the robot.

  ### Fields
  - __code__: the error code
  - __severity__: the severity of the error
  - __robot_id__: the robot ID, from Orbital
  - __user_id__: the user ID, from Orbital
  - __serial__: the robot serial number
  - __firmware__: the robot firmware at the time of event emission in Orbital
  - __robot_timestamp__: timestamp of event emission on the robot
  """

  use TypedStruct

  alias ElixirAvro.AvroType.Value.Decoder
  alias ElixirAvro.AvroType.Value.Encoder

  @expected_keys MapSet.new([
                   "code",
                   "severity",
                   "robot_id",
                   "user_id",
                   "serial",
                   "firmware",
                   "robot_timestamp"
                 ])

  typedstruct do
    field(:code, String.t(), enforce: true)
    field(:severity, String.t(), enforce: true)
    field(:robot_id, String.t(), enforce: true)
    field(:user_id, nil | String.t(), enforce: false)
    field(:serial, String.t(), enforce: true)
    field(:firmware, nil | String.t(), enforce: false)
    field(:robot_timestamp, String.t(), enforce: true)
  end

  @module_prefix Satellite

  def to_avro(%__MODULE__{} = struct) do
    {:ok,
     %{
       "code" =>
         Encoder.encode_value!(
           struct.code,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         ),
       "severity" =>
         Encoder.encode_value!(
           struct.severity,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         ),
       "robot_id" =>
         Encoder.encode_value!(
           struct.robot_id,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         ),
       "user_id" =>
         Encoder.encode_value!(
           struct.user_id,
           %ElixirAvro.AvroType.Union{
             values: %{
               0 => %ElixirAvro.AvroType.Primitive{name: "null", custom_props: []},
               1 => %ElixirAvro.AvroType.Primitive{
                 name: "string",
                 custom_props: [
                   %ElixirAvro.AvroType.CustomProp{name: "logicalType", value: "uuid"}
                 ]
               }
             }
           },
           @module_prefix
         ),
       "serial" =>
         Encoder.encode_value!(
           struct.serial,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         ),
       "firmware" =>
         Encoder.encode_value!(
           struct.firmware,
           %ElixirAvro.AvroType.Union{
             values: %{
               0 => %ElixirAvro.AvroType.Primitive{name: "null", custom_props: []},
               1 => %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []}
             }
           },
           @module_prefix
         ),
       "robot_timestamp" =>
         Encoder.encode_value!(
           struct.robot_timestamp,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         )
     }}
  end

  def from_avro(%{
        "code" => code,
        "severity" => severity,
        "robot_id" => robot_id,
        "user_id" => user_id,
        "serial" => serial,
        "firmware" => firmware,
        "robot_timestamp" => robot_timestamp
      }) do
    {:ok,
     %__MODULE__{
       code:
         Decoder.decode_value!(
           code,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         ),
       severity:
         Decoder.decode_value!(
           severity,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         ),
       robot_id:
         Decoder.decode_value!(
           robot_id,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         ),
       user_id:
         Decoder.decode_value!(
           user_id,
           %ElixirAvro.AvroType.Union{
             values: %{
               0 => %ElixirAvro.AvroType.Primitive{name: "null", custom_props: []},
               1 => %ElixirAvro.AvroType.Primitive{
                 name: "string",
                 custom_props: [
                   %ElixirAvro.AvroType.CustomProp{name: "logicalType", value: "uuid"}
                 ]
               }
             }
           },
           @module_prefix
         ),
       serial:
         Decoder.decode_value!(
           serial,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         ),
       firmware:
         Decoder.decode_value!(
           firmware,
           %ElixirAvro.AvroType.Union{
             values: %{
               0 => %ElixirAvro.AvroType.Primitive{name: "null", custom_props: []},
               1 => %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []}
             }
           },
           @module_prefix
         ),
       robot_timestamp:
         Decoder.decode_value!(
           robot_timestamp,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         )
     }}
  rescue
    e -> {:error, inspect(e)}
  end

  def from_avro(%{} = invalid) do
    actual = invalid |> Map.keys() |> MapSet.new()
    missing = @expected_keys |> MapSet.difference(actual) |> Enum.join(", ")
    {:error, "Missing keys: " <> missing}
  end

  def from_avro(_) do
    {:error, "Expected a map"}
  end
end
