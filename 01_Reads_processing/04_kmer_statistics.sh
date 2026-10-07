#!/usr/bin/env bash
# k-mer profile (Jellyfish) + genome size / heterozygosity (GenomeScope 2.0)
# k = 21 and k = 51 were compared; k = 51 gave the size closest to the expected ~2.3 Gb.
set -euo pipefail
conda activate genome_assembly

READS="avati.hifi_combined.fastq.gz"
SAMPLE="avati"
K=51
THREADS=32
GENOMESCOPE=~/genomescope2.0/genomescope.R

OUT=kmer_analysis_${SAMPLE}/k${K}; mkdir -p $OUT
jellyfish count -C -m $K -s 10G -t $THREADS -o $OUT/${SAMPLE}.jf <(zcat "$READS")
# -h 1000000 avoids the truncation peak at coverage = 10000
jellyfish histo -t $THREADS -h 1000000 $OUT/${SAMPLE}.jf > $OUT/${SAMPLE}.histo

Rscript $GENOMESCOPE -i $OUT/${SAMPLE}.histo -o $OUT/genomescope -k $K -p 2 -n $SAMPLE
