#!/usr/bin/env bash
# Contig assembly with hifiasm (default parameters, HiFi only)
# Outputs: primary (p_ctg) and two pseudo-haplotypes (hap1.p_ctg / hap2.p_ctg)
set -euo pipefail
conda activate genome_assembly

READS="avati.hifi_combined.fastq.gz"
PREFIX="avati.asm"
THREADS=48

mkdir -p hifiasm && cd hifiasm
nohup hifiasm -o $PREFIX -t $THREADS ../$READS > hifiasm.log 2>&1

for g in bp.p_ctg bp.hap1.p_ctg bp.hap2.p_ctg; do
    awk '/^S/{print ">"$2; print $3}' ${PREFIX}.${g}.gfa > ${PREFIX}.${g}.fa
done
