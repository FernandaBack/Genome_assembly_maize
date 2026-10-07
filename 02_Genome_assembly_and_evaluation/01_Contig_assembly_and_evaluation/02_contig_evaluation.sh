#!/usr/bin/env bash
#############################################
# Assembly evaluation: QUAST, BUSCO, Merqury
#############################################
set -euo pipefail
conda activate genome_assembly

PRIMARY="avati.asm.bp.p_ctg.fa"
HAP1="avati.asm.bp.hap1.p_ctg.fa"
HAP2="avati.asm.bp.hap2.p_ctg.fa"
READS="avati.hifi_combined.fastq.gz"
REF="Zm-B73-REFERENCE-NAM-5.0.fa"      # optional, for reference-based QUAST
THREADS=24
K=19                                    # best_k for ~2.3 Gb genome (k=21 also tested)

#----------------- QUAST -----------------
quast.py $PRIMARY $HAP1 $HAP2 -t $THREADS --large -o quast_results
# reference-based (heavy: minimap2 ~140 GB RAM per run — do NOT run several in parallel)
# quast.py $PRIMARY -r $REF --large -t $THREADS -o quast_ref_B73

#----------------- BUSCO -----------------
# BBTools stats.sh inside BUSCO runs out of memory with large genomes.
# Workaround: a wrapper forcing -Xmx64g placed first in PATH.
mkdir -p ~/busco_wrappers
cat > ~/busco_wrappers/stats.sh <<'W'
#!/usr/bin/env bash
exec "$(dirname $(which -a stats.sh | sed -n 2p))/stats.sh" -Xmx64g "$@"
W
chmod +x ~/busco_wrappers/stats.sh
export PATH=~/busco_wrappers:$PATH

for ASM in $PRIMARY $HAP1 $HAP2; do
    busco -i $ASM -l embryophyta_odb10 -m genome --miniprot \
          -c $THREADS -o busco_$(basename $ASM .fa) --out_path busco_results
done

#----------------- Merqury -----------------
# Required: without it meryl segfaults on large k-mer databases
ulimit -s unlimited
export MERQURY=/path/to/merqury

mkdir -p merqury_results_k${K} && cd merqury_results_k${K}
meryl count k=$K threads=$THREADS memory=200 ../$READS output reads.k${K}.meryl
# phased pair (hap1 + hap2) and primary run separately — run them sequentially
$MERQURY/merqury.sh reads.k${K}.meryl ../$HAP1 ../$HAP2 haps_k${K}
$MERQURY/merqury.sh reads.k${K}.meryl ../$PRIMARY pctg_k${K}
