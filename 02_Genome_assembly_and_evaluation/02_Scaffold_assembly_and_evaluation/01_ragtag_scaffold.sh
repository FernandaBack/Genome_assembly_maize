#!/usr/bin/env bash
# Reference-guided scaffolding with RagTag (no Hi-C data available)
# Reference: B73 NAM 5.0 (MaizeGDB)
# Both modes were tested; the "nocorrect" version was kept — misassembly correction
# fragmented the assembly (N90 dropped to ~100 kb).
set -euo pipefail
conda activate genome_assembly

REF="Zm-B73-REFERENCE-NAM-5.0.fa"
SAMPLE="avati"
THREADS=24

for ASM in pctg:${SAMPLE}.asm.bp.p_ctg.fa hap1:${SAMPLE}.asm.bp.hap1.p_ctg.fa hap2:${SAMPLE}.asm.bp.hap2.p_ctg.fa; do
    NAME=${ASM%%:*}; FA=${ASM#*:}

    ragtag.py scaffold $REF $FA -t $THREADS -o ragtag_scaffold_${NAME}_nocorrect

    # optional — with misassembly correction
    # ragtag.py correct  $REF $FA -t $THREADS -o ragtag_correct_${NAME}
    # ragtag.py scaffold $REF ragtag_correct_${NAME}/ragtag.correct.fasta -t $THREADS -o ragtag_scaffold_${NAME}_correct

    mkdir -p ${SAMPLE}_scaffolds
    cp ragtag_scaffold_${NAME}_nocorrect/ragtag.scaffold.fasta ${SAMPLE}_scaffolds/${SAMPLE}_scaffold_${NAME}.fasta
done
