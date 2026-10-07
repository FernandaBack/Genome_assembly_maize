# 🧬 Maize Genome Assembly & Variant Calling

Pipeline for **de novo assembly of maize (*Zea mays*) landrace genomes** from **PacBio HiFi** reads only,
with **reference-guided scaffolding** and **SNP / structural-variant (SV) calling** against B73.

Developed during the MSc project of **Fernanda Back de Souza** (Unicamp), applied to the Brazilian landraces

---

## 📖 Pipeline overview

1. **Reads processing** — merging sequencing runs, read QC (seqkit, NanoPlot), k-mer profiling (Jellyfish + GenomeScope 2.0);
2. **Genome assembly & evaluation** — contigs (hifiasm), evaluation (QUAST, BUSCO, Merqury), reference-guided scaffolding (RagTag), file-integrity checks;
3. **Variant calling** — SNPs/indels (DeepVariant + GLnexus), SVs from reads (Sniffles2), SVs from assemblies (minimap2 + paftools), synteny and rearrangements (SyRI + plotsr), hap1 × hap2 comparison, and cross-validation between methods.

```
HiFi reads ─► QC / k-mers ─► hifiasm ─► QUAST·BUSCO·Merqury ─► RagTag (B73) ─► scaffolds
     │                                                                          │
     └──► minimap2 ─► DeepVariant ─► GLnexus  (SNPs)                            │
     └──► minimap2 ─► Sniffles2 (.snf merge)  (SVs, reads)                      │
                         paftools · SyRI · hap1×hap2 (SVs, assembly) ◄──────────┘
                                 └─► bedtools cross-validation (1 kb)
```

---

## 🗂️ Pipeline stages

| Stage | Description |
|-------|-------------|
| [📁 00 · Conda Environment](./00_Create_conda_env) | `genome_assembly` and `syri` environments |
| [📁 01 · Reads Processing](./01_Reads_processing) | Run merging, seqkit/NanoPlot, optional Filtlong, Jellyfish + GenomeScope |
| [📁 02 · Genome Assembly & Evaluation](./02_Genome_assembly_and_evaluation) | hifiasm, QUAST/BUSCO/Merqury, RagTag, integrity check |
| [📁 03 · Variant Calling](./03_Variant_calling) | DeepVariant/GLnexus, Sniffles2, paftools, SyRI, haplotypes, cross-validation |

### 03 · Variant calling in detail

| Step | Tools | Output |
|------|-------|--------|
| 01 SNP calling | minimap2 (map-hifi), DeepVariant (PACBIO), GLnexus | joint multi-sample SNP/indel VCF |
| 02 SV calling – reads | Sniffles2 (`--minsupport 12 --minsvlen 100`), bcftools | `population.final.vcf` (genotyped, no BND/TRA) |
| 03 SV calling – assembly | minimap2 (asm5), paftools.js | per-sample assembly VCF |
| 04 Synteny | SyRI, plotsr | syntenic blocks, inversions, translocations, duplications |
| 05 Haplotypes | minimap2, paftools, SyRI | hap1 × hap2 variants and synteny |
| 06 Cross-validation | bedtools window (1 kb) | SVs supported by 1, 2 or 3 methods |

---

## ⚠️ Practical notes (lessons learned)

- **Merqury / meryl segfaults** on large k-mer DBs → run with `ulimit -s unlimited`.
- **BUSCO "analysis failed"** → OutOfMemory in BBTools `stats.sh`; use the `-Xmx64g` wrapper in `02_contig_evaluation.sh`.
- **minimap2 whole-genome alignment uses ~240 GB RAM** → check `hostname` before running; never on the login node (killed silently).
- **Never let two jobs write the same output** → write to `*.tmp` and `mv` at the end.
- **Sniffles2 `--genotype-vcf` bug** (`KeyError: 'SINGLE_LEFT'`) → use the `.snf` population merge instead.
- **Silent storage corruption** (null-byte blocks) is not detected by `seqkit stats` → use `check_file_integrity.sh` and keep md5 manifests.
- RagTag with `correct` fragmented the assembly → the `nocorrect` scaffolds were kept.

---

## 🚀 Getting started

```bash
git clone https://github.com/FernandaBack/Genome_assembly_maize.git
cd Genome_assembly_maize
mamba env create -f 00_Create_conda_env/environment_genome_assembly.yml
mamba env create -f 00_Create_conda_env/environment_syri.yml
```

Edit the input variables at the top of each script (sample name, reads, reference, threads) before running.

---

## ⚙️ Requirements

- **OS:** Linux · **Package manager:** Conda/Mamba · Singularity (DeepVariant, GLnexus)
- **Hardware used:** 64 cores, ~500 GB RAM (shared node); ≥ 2 TB scratch
- **Input:** PacBio HiFi reads (`.fastq.gz`) and the B73 reference (`Zm-B73-REFERENCE-NAM-5.0`, MaizeGDB)

---

## 📚 References

- **hifiasm** — Cheng et al. 2021, *Nature Methods*
- **GenomeScope 2.0** — Ranallo-Benavidez et al. 2020, *Nature Communications*
- **QUAST** — Gurevich et al. 2013, *Bioinformatics*
- **BUSCO** — Manni et al. 2021, *Molecular Biology and Evolution*
- **Merqury** — Rhie et al. 2020, *Genome Biology*
- **RagTag** — Alonge et al. 2022, *Genome Biology*
- **DeepVariant** — Poplin et al. 2018, *Nature Biotechnology*
- **GLnexus** — Yun et al. 2021, *Bioinformatics*
- **Sniffles2** — Smolka et al. 2024, *Nature Biotechnology*
- **minimap2 / paftools** — Li 2018, *Bioinformatics*
- **SyRI** — Goel et al. 2019, *Genome Biology* · **plotsr** — Goel & Schneeberger 2022, *Bioinformatics*
- **BEDTools** — Quinlan & Hall 2010, *Bioinformatics*
- Maize pan-genome comparison: Hufford et al. 2021, *Science*
