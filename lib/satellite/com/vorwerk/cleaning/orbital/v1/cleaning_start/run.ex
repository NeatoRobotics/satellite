defmodule Satellite.Com.Vorwerk.Cleaning.Orbital.V1.CleaningStart.Run do
  @moduledoc """
  DO NOT EDIT MANUALLY: This module was automatically generated from an AVRO schema.

  ### Description


  ### Fields
  - __map__:
  - __settings__:
  """

  use TypedStruct

  alias ElixirAvro.AvroType.Value.Decoder
  alias ElixirAvro.AvroType.Value.Encoder

  @expected_keys MapSet.new(["map", "settings"])

  typedstruct do
    field :map, Satellite.Com.Vorwerk.Cleaning.Orbital.V1.CleaningStart.Map.t(), enforce: true

    field :settings, Satellite.Com.Vorwerk.Cleaning.Orbital.V1.CleaningStart.Settings.t(),
      enforce: true
  end

  @module_prefix Satellite

  def to_avro(%__MODULE__{} = struct) do
    {:ok,
     %{
       "map" =>
         Encoder.encode_value!(
           struct.map,
           "com.vorwerk.cleaning.orbital.v1.cleaning_start.Map",
           @module_prefix
         ),
       "settings" =>
         Encoder.encode_value!(
           struct.settings,
           "com.vorwerk.cleaning.orbital.v1.cleaning_start.Settings",
           @module_prefix
         )
     }}
  end

  def from_avro(%{"map" => map, "settings" => settings}) do
    {:ok,
     %__MODULE__{
       map:
         Decoder.decode_value!(
           map,
           "com.vorwerk.cleaning.orbital.v1.cleaning_start.Map",
           @module_prefix
         ),
       settings:
         Decoder.decode_value!(
           settings,
           "com.vorwerk.cleaning.orbital.v1.cleaning_start.Settings",
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
