#!/usr/bin/env bash
# Assembly-based variant calling: whole-genome alignment (minimap2) + paftools call
# minimap2 asm5 on a 2.3 Gb genome uses ~240 GB RAM — check `hostname` (never the login node).
set -euo pipefail
conda activate genome_assembly

REF="Zm-B73-REFERENCE-NAM-5.0.fa"
for SAMPLE in avati entrelacado; do
    ASM=${SAMPLE}_scaffold_pctg.fasta
    minimap2 -cx asm5 -t 32 --cs $REF $ASM > ${SAMPLE}.B73.paf.tmp \
      && mv ${SAMPLE}.B73.paf.tmp ${SAMPLE}.B73.paf
    sort -k6,6 -k8,8n ${SAMPLE}.B73.paf \
      | paftools.js call -L 10000 -f $REF -s $SAMPLE - > ${SAMPLE}.paftools.vcf
done
