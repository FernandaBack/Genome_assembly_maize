#!/usr/bin/env bash
# Multi-sample genotyped VCF via Sniffles2 native population merge (.snf).
# NOTE: the two-round approach (--genotype-vcf) fails with "KeyError: 'SINGLE_LEFT'"
# in sniffles/parallel.py (reproduced in v2.7.3 and v2.8.0) — the .snf merge avoids it.
set -euo pipefail
conda activate genome_assembly

REF="Zm-B73-REFERENCE-NAM-5.0.fa"
sniffles --input avati.snf entrelacado.snf --reference $REF \
    --vcf population.vcf.gz --threads 24

# keep PASS, drop BND/TRA
bcftools view -f PASS -e 'INFO/SVTYPE="BND" || INFO/SVTYPE="TRA"' \
    population.vcf.gz -Oz -o population.final.vcf.gz
bcftools index population.final.vcf.gz
