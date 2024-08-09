defmodule Satellite.Com.Vorwerk.Cleaning.Orbital.V1.CleaningStart.Map do
  @moduledoc """
  DO NOT EDIT MANUALLY: This module was automatically generated from an AVRO schema.

  ### Description
  Map within a run

  ### Fields
  - __floorplan_uuid__: the UUID of the floorplan this cleaning was performed on
  - __zone_uuid__: the UUID of the zone this cleaning was performed on
  - __nogo_enabled__: whether the robot was told to respect no-go zones or not
  """

  use TypedStruct

  alias ElixirAvro.AvroType.Value.Decoder
  alias ElixirAvro.AvroType.Value.Encoder

  @expected_keys MapSet.new(["floorplan_uuid", "zone_uuid", "nogo_enabled"])

  typedstruct do
    field :floorplan_uuid, nil | String.t(), enforce: false
    field :zone_uuid, nil | String.t(), enforce: false
    field :nogo_enabled, boolean(), enforce: true
  end

  @module_prefix Satellite

  def to_avro(%__MODULE__{} = struct) do
    {:ok,
     %{
       "floorplan_uuid" =>
         Encoder.encode_value!(
           struct.floorplan_uuid,
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
       "zone_uuid" =>
         Encoder.encode_value!(
           struct.zone_uuid,
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
       "nogo_enabled" =>
         Encoder.encode_value!(
           struct.nogo_enabled,
           %ElixirAvro.AvroType.Primitive{name: "boolean", custom_props: []},
           @module_prefix
         )
     }}
  end

  def from_avro(%{
        "floorplan_uuid" => floorplan_uuid,
        "zone_uuid" => zone_uuid,
        "nogo_enabled" => nogo_enabled
      }) do
    {:ok,
     %__MODULE__{
       floorplan_uuid:
         Decoder.decode_value!(
           floorplan_uuid,
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
       zone_uuid:
         Decoder.decode_value!(
           zone_uuid,
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
       nogo_enabled:
         Decoder.decode_value!(
           nogo_enabled,
           %ElixirAvro.AvroType.Primitive{name: "boolean", custom_props: []},
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
