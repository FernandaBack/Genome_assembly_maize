#!/usr/bin/env bash
# Cross-validation of SVs from the three approaches (reads / assembly / SyRI), 1 kb window
set -euo pipefail
conda activate genome_assembly
W=1000

for S in avati entrelacado; do
    # VCF -> BED (chrom, start, end, type)
    bcftools view -s $S -i 'GT="alt"' ../02_SV_calling_reads/population.final.vcf.gz \
      | bcftools query -f '%CHROM\t%POS0\t%END\t%INFO/SVTYPE\n' > ${S}.reads.bed
    awk '!/^#/ && length($4)!=length($5) && (length($4)>=50||length($5)>=50){print $1"\t"$2-1"\t"$2+length($4)}' \
        ../03_SV_calling_assembly/${S}.paftools.vcf > ${S}.assembly.bed
    awk '$11 ~ /^(INV|TRANS|INVTR|DUP|INVDP|DEL|INS)$/ {print $1"\t"$2-1"\t"$3"\t"$11}' \
        ../04_Synteny_SyRI/${S}_syri.out > ${S}.syri.bed

    R_A=$(bedtools window -a ${S}.reads.bed    -b ${S}.assembly.bed -w $W -u | wc -l)
    A_R=$(bedtools window -a ${S}.assembly.bed -b ${S}.reads.bed    -w $W -u | wc -l)
    ALL=$(bedtools window -a ${S}.reads.bed -b ${S}.assembly.bed -w $W -u \
          | bedtools window -a - -b ${S}.syri.bed -w $W -u | wc -l)
    echo -e "$S\treads_supported_by_assembly=$R_A\tassembly_supported_by_reads=$A_R\tconsensus_3_methods=$ALL"
done
