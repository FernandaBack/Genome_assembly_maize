# Conda environments

Two environments are used. SyRI does not resolve under Python 3.10, so it lives in its own environment.

```bash
mamba env create -f environment_genome_assembly.yml   # reads, assembly, evaluation, SNP/SV calling
mamba env create -f environment_syri.yml              # SyRI + plotsr (Python 3.11)

conda activate genome_assembly
```

Tools installed outside conda:
- **GenomeScope 2.0** – cloned from GitHub and run with `Rscript genomescope.R`
- **Merqury** – cloned from GitHub; `export MERQURY=/path/to/merqury`
- **DeepVariant / GLnexus** – run through Singularity images

> Tip: keep environments and data on the scratch filesystem rather than `$HOME`.
