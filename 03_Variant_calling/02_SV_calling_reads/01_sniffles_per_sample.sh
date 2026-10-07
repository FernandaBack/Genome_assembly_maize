#!/usr/bin/env bash
# Read-based SV calling with Sniffles2 (one .snf per sample for population merge)
set -euo pipefail
conda activate genome_assembly

REF="Zm-B73-REFERENCE-NAM-5.0.fa"
for SAMPLE in avati entrelacado; do
    sniffles --input ../01_SNP_calling/${SAMPLE}.B73.bam --reference $REF \
        --vcf ${SAMPLE}.sniffles.vcf.gz --snf ${SAMPLE}.snf \
        --minsupport 12 --minsvlen 100 \
        --max-splits-base 2 --max-splits-kb 0 \
        --min-alignment-length 5000 --threads 24
done
