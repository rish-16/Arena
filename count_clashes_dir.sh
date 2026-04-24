#!/usr/bin/env bash
# Usage: ./count_clashes_dir.sh <pdb_dir> [option]
# Runs Arena_counter on every .pdb file in pdb_dir and prints per-file clash
# counts plus summary statistics (min, max, mean, total).

set -euo pipefail

ARENA_DIR="$(cd "$(dirname "$0")" && pwd)"
COUNTER="$ARENA_DIR/Arena_counter"

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <pdb_dir> [option]"
    echo "  option: Arena_counter option (default 5)"
    exit 1
fi

PDB_DIR="$1"
OPTION="${2:-5}"
TMPFILE=$(mktemp)

if [[ ! -x "$COUNTER" ]]; then
    echo "Error: Arena_counter not found or not executable at $COUNTER"
    echo "Run: cd $ARENA_DIR && make Arena_counter"
    exit 1
fi

shopt -s nullglob
pdbs=("$PDB_DIR"/*.pdb)
if [[ ${#pdbs[@]} -eq 0 ]]; then
    echo "No .pdb files found in $PDB_DIR"
    exit 1
fi

printf "%-50s  %s\n" "FILE" "CLASHES"
printf "%-50s  %s\n" "----" "-------"

total=0
count=0
min=""
max=""

for pdb in "${pdbs[@]}"; do
    out=$(mktemp)
    "$COUNTER" "$pdb" "$out" "$OPTION" 2>/dev/null || true
    clashes=$(cat "$out")
    rm -f "$out"

    printf "%-50s  %d\n" "$(basename "$pdb")" "$clashes"
    echo "$clashes" >> "$TMPFILE"

    total=$((total + clashes))
    count=$((count + 1))
    [[ -z "$min" || $clashes -lt $min ]] && min=$clashes
    [[ -z "$max" || $clashes -gt $max ]] && max=$clashes
done

if [[ $count -gt 0 ]]; then
    mean=$(awk "BEGIN {printf \"%.2f\", $total/$count}")
    echo ""
    echo "--- Summary ($count files) ---"
    printf "  Total:  %d\n" "$total"
    printf "  Mean:   %s\n" "$mean"
    printf "  Min:    %d\n" "$min"
    printf "  Max:    %d\n" "$max"
fi

rm -f "$TMPFILE"
