#!/usr/bin/env bash
# Combine HiFi runs from the same library/individual before assembly.
# Raw reads are concatenated directly (no filtering step) — gzip streams can be concatenated.
set -euo pipefail

SAMPLE="avati"                                  # avati | entrelacado
RUNS=( run1.hifi_reads.fastq.gz run2.hifi_reads.fastq.gz )
OUT="${SAMPLE}.hifi_combined.fastq.gz"

cat "${RUNS[@]}" > "${OUT}.tmp" && mv "${OUT}.tmp" "$OUT"
pigz -t "$OUT" && echo "gzip integrity OK: $OUT"
