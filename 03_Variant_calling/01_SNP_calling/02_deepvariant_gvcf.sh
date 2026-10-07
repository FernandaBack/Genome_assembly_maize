#!/usr/bin/env bash
# Per-sample SNP/indel calling with DeepVariant (PACBIO model), emitting gVCF for joint calling
set -euo pipefail

REF="Zm-B73-REFERENCE-NAM-5.0.fa"
SIF="deepvariant.sif"          # singularity pull docker://google/deepvariant:<version>
THREADS=32

for SAMPLE in avati entrelacado; do
    singularity exec -B $PWD $SIF /opt/deepvariant/bin/run_deepvariant \
        --model_type=PACBIO --ref=$REF --reads=${SAMPLE}.B73.bam \
        --output_vcf=${SAMPLE}.dv.vcf.gz --output_gvcf=${SAMPLE}.dv.g.vcf.gz \
        --num_shards=$THREADS --intermediate_results_dir tmp_${SAMPLE}
done
