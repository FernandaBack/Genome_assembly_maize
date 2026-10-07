#!/usr/bin/env bash
# Align HiFi reads of each sample to the B73 reference
set -euo pipefail
conda activate genome_assembly

REF="Zm-B73-REFERENCE-NAM-5.0.fa"
THREADS=32
samtools faidx $REF

for SAMPLE in avati entrelacado; do
    minimap2 -ax map-hifi -t $THREADS --MD -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}" \
        $REF ${SAMPLE}.hifi_combined.fastq.gz \
      | samtools sort -@ 8 -m 4G -o ${SAMPLE}.B73.bam.tmp - \
      && mv ${SAMPLE}.B73.bam.tmp ${SAMPLE}.B73.bam     # write to .tmp, move at the end
    samtools index ${SAMPLE}.B73.bam
done
