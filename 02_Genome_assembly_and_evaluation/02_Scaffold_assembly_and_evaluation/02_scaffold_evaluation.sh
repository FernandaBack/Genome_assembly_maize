#!/usr/bin/env bash
# Same metrics as the contig step, on the scaffolds — reuses the meryl DB already built.
set -euo pipefail
conda activate genome_assembly
ulimit -s unlimited

SAMPLE="avati"
DIR=${SAMPLE}_scaffolds
MERYL_DB=../01_Contig_assembly_and_evaluation/merqury_results_k19/reads.k19.meryl
THREADS=24
export PATH=~/busco_wrappers:$PATH

quast.py $DIR/*.fasta -t $THREADS --large --min-contig 500 -o quast_scaffolds

for FA in $DIR/*.fasta; do
    busco -i $FA -l embryophyta_odb10 -m genome --miniprot -c $THREADS \
          -o busco_$(basename $FA .fasta) --out_path busco_scaffolds
done

mkdir -p merqury_scaffolds_k19 && cd merqury_scaffolds_k19
$MERQURY/merqury.sh $MERYL_DB ../$DIR/${SAMPLE}_scaffold_hap1.fasta ../$DIR/${SAMPLE}_scaffold_hap2.fasta haps
$MERQURY/merqury.sh $MERYL_DB ../$DIR/${SAMPLE}_scaffold_pctg.fasta pctg
