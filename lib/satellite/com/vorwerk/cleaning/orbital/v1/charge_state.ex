defmodule Satellite.Com.Vorwerk.Cleaning.Orbital.V1.ChargeState do
  @moduledoc """
  DO NOT EDIT MANUALLY: This module was automatically generated from an AVRO schema.

  ### Description
  Charge State event received from a robot

  ### Fields
  - __charge__: percentage level of the battery
  - __is_charging__: whether the robot is charging at event emission
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
                   "charge",
                   "is_charging",
                   "robot_id",
                   "user_id",
                   "serial",
                   "firmware",
                   "robot_timestamp"
                 ])

  typedstruct do
    field(:charge, integer(), enforce: true)
    field(:is_charging, boolean(), enforce: true)
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
       "charge" =>
         Encoder.encode_value!(
           struct.charge,
           %ElixirAvro.AvroType.Primitive{name: "int", custom_props: []},
           @module_prefix
         ),
       "is_charging" =>
         Encoder.encode_value!(
           struct.is_charging,
           %ElixirAvro.AvroType.Primitive{name: "boolean", custom_props: []},
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
        "charge" => charge,
        "is_charging" => is_charging,
        "robot_id" => robot_id,
        "user_id" => user_id,
        "serial" => serial,
        "firmware" => firmware,
        "robot_timestamp" => robot_timestamp
      }) do
    {:ok,
     %__MODULE__{
       charge:
         Decoder.decode_value!(
           charge,
           %ElixirAvro.AvroType.Primitive{name: "int", custom_props: []},
           @module_prefix
         ),
       is_charging:
         Decoder.decode_value!(
           is_charging,
           %ElixirAvro.AvroType.Primitive{name: "boolean", custom_props: []},
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
