#!/usr/bin/env bash
# OPTIONAL — quality/length filtering tested with Filtlong (Q15, Q20, Q30, min length 12 kb).
# Final assemblies used the raw (unfiltered) HiFi reads; this script is kept for reproducibility.
set -euo pipefail
conda activate genome_assembly

READS="raw.hifi_reads.fastq.gz"
for Q in 15 20 30; do
    nohup bash -c "filtlong --min_mean_q $Q $READS | pigz -p 8 > hifi.filt.q${Q}.fastq.gz" \
        > filtlong_q${Q}.log 2>&1 &
done
# filtlong --min_length 12000 $READS | pigz > hifi.filt.minlen12kb.fastq.gz
