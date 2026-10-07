#!/usr/bin/env bash
# Within-individual heterozygosity: hap1 x hap2 (minimap2 + paftools + SyRI)
# Ti/Tv ~2.7 between haplotypes supports real heterozygosity rather than phasing errors.
set -euo pipefail

for SAMPLE in avati entrelacado; do
    H1=${SAMPLE}_scaffold_hap1.fasta; H2=${SAMPLE}_scaffold_hap2.fasta

    conda activate genome_assembly
    minimap2 -cx asm5 -t 32 --cs $H1 $H2 | sort -k6,6 -k8,8n \
      | paftools.js call -f $H1 -s ${SAMPLE}_hap2 - > ${SAMPLE}_hap_variants.vcf
    bcftools stats ${SAMPLE}_hap_variants.vcf | grep '^TSTV'

    conda activate syri
    minimap2 -ax asm5 -t 32 --eqx $H1 $H2 | samtools sort -o ${SAMPLE}_hap.bam && samtools index ${SAMPLE}_hap.bam
    syri -c ${SAMPLE}_hap.bam -r $H1 -q $H2 -F B --prefix ${SAMPLE}_hap_ --nc 8
done
