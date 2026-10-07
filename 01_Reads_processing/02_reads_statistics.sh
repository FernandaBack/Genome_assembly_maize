#!/usr/bin/env bash
# Read-level QC: seqkit stats + NanoPlot
set -euo pipefail
conda activate genome_assembly

READS="avati.hifi_combined.fastq.gz"
SAMPLE="avati"
THREADS=24

mkdir -p seqkit nanoplot_${SAMPLE}
seqkit stats -a -T -j $THREADS "$READS" > seqkit/${SAMPLE}.stats.tsv

nohup NanoPlot --fastq "$READS" -t $THREADS \
    --outdir nanoplot_${SAMPLE} --loglength --N50 \
    > nanoplot_${SAMPLE}.log 2>&1 &
