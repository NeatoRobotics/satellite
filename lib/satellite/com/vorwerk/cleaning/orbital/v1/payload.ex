defmodule Satellite.Com.Vorwerk.Cleaning.Orbital.V1.Payload do
  @moduledoc """
  DO NOT EDIT MANUALLY: This module was automatically generated from an AVRO schema.

  ### Description
  Any payload received by Orbital

  ### Fields
  - __content__:
  """

  use TypedStruct

  alias ElixirAvro.AvroType.Value.Decoder
  alias ElixirAvro.AvroType.Value.Encoder

  @expected_keys MapSet.new(["content"])

  typedstruct do
    field(
      :content,
      %{
        String.t() =>
          nil
          | String.t()
          | integer()
          | boolean()
          | Satellite.Com.Vorwerk.Cleaning.Orbital.V1.Payload.t()
      },
      enforce: true
    )
  end

  @module_prefix Satellite

  def to_avro(%__MODULE__{} = struct) do
    {:ok,
     %{
       "content" =>
         Encoder.encode_value!(
           struct.content,
           %ElixirAvro.AvroType.Map{
             type: %ElixirAvro.AvroType.Union{
               values: %{
                 0 => %ElixirAvro.AvroType.Primitive{name: "null", custom_props: []},
                 1 => %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
                 2 => %ElixirAvro.AvroType.Primitive{name: "long", custom_props: []},
                 3 => %ElixirAvro.AvroType.Primitive{name: "boolean", custom_props: []},
                 4 => "com.vorwerk.cleaning.orbital.v1.Payload"
               }
             },
             custom_props: [%ElixirAvro.AvroType.CustomProp{name: "default", value: "null"}]
           },
           @module_prefix
         )
     }}
  end

  def to_avro(_) do
    {:error, :not_supported}
  end

  def from_avro(%{"content" => content}) do
    {:ok,
     %__MODULE__{
       content:
         Decoder.decode_value!(
           content,
           %ElixirAvro.AvroType.Map{
             type: %ElixirAvro.AvroType.Union{
               values: %{
                 0 => %ElixirAvro.AvroType.Primitive{name: "null", custom_props: []},
                 1 => %ElixirAvro.AvroType.Primitive{name: "string", custom_props: []},
                 2 => %ElixirAvro.AvroType.Primitive{name: "long", custom_props: []},
                 3 => %ElixirAvro.AvroType.Primitive{name: "boolean", custom_props: []},
                 4 => "com.vorwerk.cleaning.orbital.v1.Payload"
               }
             },
             custom_props: [%ElixirAvro.AvroType.CustomProp{name: "default", value: "null"}]
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
