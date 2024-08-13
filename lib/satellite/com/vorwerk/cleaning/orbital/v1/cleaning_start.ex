defmodule Satellite.Com.Vorwerk.Cleaning.Orbital.V1.CleaningStart do
  @moduledoc """
  DO NOT EDIT MANUALLY: This module was automatically generated from an AVRO schema.

  ### Description
  Cleaning Start event received from a robot

  ### Fields
  - __started_by__: how was the cleaning run triggered
  - __runs__: the cleaning runs in this map
  - __success__: whether the cleaning run was started successfully or not
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
                   "started_by",
                   "runs",
                   "success",
                   "robot_id",
                   "user_id",
                   "serial",
                   "firmware",
                   "robot_timestamp"
                 ])

  typedstruct do
    field(:started_by, String.t(), enforce: true)
    field(:runs, [Satellite.Com.Vorwerk.Cleaning.Orbital.V1.CleaningStart.Run.t()], enforce: true)
    field(:success, boolean(), enforce: true)
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
       "started_by" =>
         Encoder.encode_value!(
           struct.started_by,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         ),
       "runs" =>
         Encoder.encode_value!(
           struct.runs,
           %ElixirAvro.AvroType.Array{
             type: "com.vorwerk.cleaning.orbital.v1.cleaning_start.run",
             custom_props: []
           },
           @module_prefix
         ),
       "success" =>
         Encoder.encode_value!(
           struct.success,
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

  def to_avro(_) do
    {:error, :not_supported}
  end

  def from_avro(%{
        "started_by" => started_by,
        "runs" => runs,
        "success" => success,
        "robot_id" => robot_id,
        "user_id" => user_id,
        "serial" => serial,
        "firmware" => firmware,
        "robot_timestamp" => robot_timestamp
      }) do
    {:ok,
     %__MODULE__{
       started_by:
         Decoder.decode_value!(
           started_by,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         ),
       runs:
         Decoder.decode_value!(
           runs,
           %ElixirAvro.AvroType.Array{
             type: "com.vorwerk.cleaning.orbital.v1.cleaning_start.run",
             custom_props: []
           },
           @module_prefix
         ),
       success:
         Decoder.decode_value!(
           success,
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
