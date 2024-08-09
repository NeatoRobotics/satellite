#!/usr/bin/env bash

echo "AVRO to Elixir code generation script"

# Get current directory.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Cleaning existing files..."
rm -rf lib/satellite/com

echo "Generating Elixir code..."
#  Generate all avro converted files with elixir_avro
mix elixir_avro_codegen --schemas-path priv/schemas --target-path lib/ --prefix Satellite

#  Generate all avro converted files with avro by containing folder, can be useful for debugging
#for dir in $(find ${DIR}/priv/schemas/ -name '*.avsc' -print0 | xargs -0 -n1 dirname | sort | uniq); do
#  files=$(find "${dir}" -name '*.avsc')
#
#  echo "dir: ${dir}"
#  echo "files: ${files}"
#
#  mix elixir_avro_codegen --schemas-path ${dir}/ --target-path lib/ --prefix Satellite
# done

echo "Done"
