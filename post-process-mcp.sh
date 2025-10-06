#!/usr/bin/env bash

set -x

output_dir="$1"  # Output directory passed as first argument
file_path="$2"   # Generated file path from OpenAPI

if [[ "$file_path" == *Api.cs ]]; then
    new_name=$(basename "$file_path" | sed 's/Api/McpToolBase/g')
    mc_dir="$output_dir/Interface"
    mkdir -p "$mc_dir"
    mv "$file_path" "$mc_dir/$new_name"
fi
rm -rf Editor