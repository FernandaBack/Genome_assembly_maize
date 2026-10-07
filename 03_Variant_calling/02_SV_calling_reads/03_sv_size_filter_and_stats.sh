#!/usr/bin/env bash
# Cap very large SVs (mostly INV/DUP, up to hundreds of Mb) and count SVs per type/sample
set -euo pipefail
conda activate genome_assembly
VCF=population.final.vcf.gz

for MAX in 1000000:max1Mb 10000000:max10Mb; do
    L=${MAX%%:*}; TAG=${MAX#*:}
    bcftools view -i "INFO/SVLEN<=${L} && INFO/SVLEN>=-${L}" $VCF -Oz -o population.final.${TAG}.vcf.gz
done

# counts per sample and SV type (non-ref genotypes)
for S in avati entrelacado; do
    echo "== $S"
    bcftools view -s $S -i 'GT="alt"' population.final.max10Mb.vcf.gz \
      | bcftools query -f '%INFO/SVTYPE\n' | sort | uniq -c
done
