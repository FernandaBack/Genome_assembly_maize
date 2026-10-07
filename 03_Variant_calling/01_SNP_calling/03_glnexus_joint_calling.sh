#!/usr/bin/env bash
# Joint genotyping of gVCFs with GLnexus -> single multi-sample VCF
set -euo pipefail
conda activate genome_assembly
SIF="glnexus.sif"              # singularity pull docker://ghcr.io/dnanexus-rnd/glnexus:<version>

singularity exec -B $PWD $SIF glnexus_cli --config DeepVariant_unfiltered \
    avati.dv.g.vcf.gz entrelacado.dv.g.vcf.gz \
  | bcftools view -Oz -o snp_joint.vcf.gz - && bcftools index snp_joint.vcf.gz

# summary: Ti/Tv, het/hom per sample
bcftools stats -s - snp_joint.vcf.gz > snp_joint.stats.txt
