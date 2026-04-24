#!/usr/bin/env bash
# Usage: ./run_arena_dir.sh <input_dir> <output_dir> [option]
# Runs Arena on every .pdb file in input_dir and writes results to output_dir.

set -euo pipefail

ARENA_DIR="$(cd "$(dirname "$0")" && pwd)"
ARENA="$ARENA_DIR/Arena"

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <input_dir> <output_dir> [option]"
    echo "  option: Arena option (default 7)"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
OPTION="${3:-7}"

if [[ ! -x "$ARENA" ]]; then
    echo "Error: Arena not found or not executable at $ARENA"
    echo "Run: cd $ARENA_DIR && make Arena"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

shopt -s nullglob
pdbs=("$INPUT_DIR"/*.pdb)
if [[ ${#pdbs[@]} -eq 0 ]]; then
    echo "No .pdb files found in $INPUT_DIR"
    exit 1
fi

echo "Running Arena (option $OPTION) on ${#pdbs[@]} files -> $OUTPUT_DIR"
echo ""

for pdb in "${pdbs[@]}"; do
    name="$(basename "$pdb" .pdb)"
    out="$OUTPUT_DIR/${name}.arena.pdb"
    echo "  $name.pdb -> $(basename "$out")"
    "$ARENA" "$pdb" "$out" "$OPTION"
done

echo ""
echo "Done. ${#pdbs[@]} files written to $OUTPUT_DIR"
