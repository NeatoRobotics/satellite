defmodule Satellite.Com.Vorwerk.Cleaning.Orbital.V1.CleaningStart.Settings do
  @moduledoc """
  DO NOT EDIT MANUALLY: This module was automatically generated from an AVRO schema.

  ### Description
  Settings within a run

  ### Fields
  - __navigation_mode__: a robot setting on how to navigate during cleaning
  - __mode__: a robot setting on how powerful the vacuuming should be
  """

  use TypedStruct

  alias ElixirAvro.AvroType.Value.Decoder
  alias ElixirAvro.AvroType.Value.Encoder

  @expected_keys MapSet.new(["navigation_mode", "mode"])

  typedstruct do
    field(:navigation_mode, String.t(), enforce: true)
    field(:mode, String.t(), enforce: true)
  end

  @module_prefix Satellite

  def to_avro(%__MODULE__{} = struct) do
    {:ok,
     %{
       "navigation_mode" =>
         Encoder.encode_value!(
           struct.navigation_mode,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         ),
       "mode" =>
         Encoder.encode_value!(
           struct.mode,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         )
     }}
  end

  def to_avro(_) do
    {:error, :not_supported}
  end

  def from_avro(%{"navigation_mode" => navigation_mode, "mode" => mode}) do
    {:ok,
     %__MODULE__{
       navigation_mode:
         Decoder.decode_value!(
           navigation_mode,
           %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
           @module_prefix
         ),
       mode:
         Decoder.decode_value!(
           mode,
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
