#!/usr/bin/env bash
# Synteny and structural rearrangements (inversions, translocations, duplications) with SyRI + plotsr
set -euo pipefail
conda activate syri

REF="Zm-B73-REFERENCE-NAM-5.0.fa"
for SAMPLE in avati entrelacado; do
    QRY=${SAMPLE}_scaffold_pctg.fasta
    # SyRI requires matching chromosome names/orientation between ref and query
    minimap2 -ax asm5 -t 32 --eqx $REF $QRY | samtools sort -@ 8 -o ${SAMPLE}.B73.bam
    samtools index ${SAMPLE}.B73.bam
    syri -c ${SAMPLE}.B73.bam -r $REF -q $QRY -F B --prefix ${SAMPLE}_ --nc 8
    printf "%s\tB73\n%s\t%s\n" $REF $QRY $SAMPLE > ${SAMPLE}_genomes.txt
    plotsr --sr ${SAMPLE}_syri.out --genomes ${SAMPLE}_genomes.txt -o ${SAMPLE}_plotsr.pdf -H 8 -W 6
done
