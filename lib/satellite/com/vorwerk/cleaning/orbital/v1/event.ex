defmodule Satellite.Com.Vorwerk.Cleaning.Orbital.V1.Event do
  @moduledoc """
  DO NOT EDIT MANUALLY: This module was automatically generated from an AVRO schema.

  ### Description
  Event emitted by Orbital

  ### Fields
  - __id__: the event ID, from Orbital
  - __origin__: the event type, from Orbital
  - __timestamp__: timestamp of message generation
  - __payload__:
  """

  use TypedStruct

  alias ElixirAvro.AvroType.Value.Decoder
  alias ElixirAvro.AvroType.Value.Encoder

  @expected_keys MapSet.new(["id", "origin", "timestamp", "payload"])

  typedstruct do
    field :id, String.t(), enforce: true
    field :origin, String.t(), enforce: true
    field :timestamp, String.t(), enforce: true

    field :payload,
          Satellite.Com.Vorwerk.Cleaning.Orbital.V1.ChargeState.t()
          | Satellite.Com.Vorwerk.Cleaning.Orbital.V1.CleaningEnd.t()
          | Satellite.Com.Vorwerk.Cleaning.Orbital.V1.CleaningStart.t()
          | Satellite.Com.Vorwerk.Cleaning.Orbital.V1.DockingState.t()
          | Satellite.Com.Vorwerk.Cleaning.Orbital.V1.RobotError.t()
          | Satellite.Com.Vorwerk.Cleaning.Orbital.V1.RobotNotification.t(),
          enforce: false
  end

  @module_prefix Satellite

  def to_avro(%__MODULE__{} = struct) do
    {:ok,
     %{
       "id" =>
         Encoder.encode_value!(
           struct.id,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         ),
       "origin" =>
         Encoder.encode_value!(
           struct.origin,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         ),
       "timestamp" =>
         Encoder.encode_value!(
           struct.timestamp,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         ),
       "payload" =>
         Encoder.encode_value!(
           struct.payload,
           %ElixirAvro.AvroType.Union{
             values: %{
               0 => "com.vorwerk.cleaning.orbital.v1.ChargeState",
               1 => "com.vorwerk.cleaning.orbital.v1.CleaningEnd",
               2 => "com.vorwerk.cleaning.orbital.v1.CleaningStart",
               3 => "com.vorwerk.cleaning.orbital.v1.DockingState",
               4 => "com.vorwerk.cleaning.orbital.v1.RobotError",
               5 => "com.vorwerk.cleaning.orbital.v1.RobotNotification"
             }
           },
           @module_prefix
         )
     }}
  end

  def from_avro(%{"id" => id, "origin" => origin, "timestamp" => timestamp, "payload" => payload}) do
    {:ok,
     %__MODULE__{
       id: Decoder.decode_value!(id, %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []}, @module_prefix),
       origin:
         Decoder.decode_value!(origin, %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []}, @module_prefix),
       timestamp:
         Decoder.decode_value!(
           timestamp,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         ),
       payload:
         Decoder.decode_value!(
           payload,
           %ElixirAvro.AvroType.Union{
             values: %{
               0 => "com.vorwerk.cleaning.orbital.v1.ChargeState",
               1 => "com.vorwerk.cleaning.orbital.v1.CleaningEnd",
               2 => "com.vorwerk.cleaning.orbital.v1.CleaningStart",
               3 => "com.vorwerk.cleaning.orbital.v1.DockingState",
               4 => "com.vorwerk.cleaning.orbital.v1.RobotError",
               5 => "com.vorwerk.cleaning.orbital.v1.RobotNotification"
             }
           },
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
