# Shotgun Metagenomics Pipeline

This repository contains two SLURM batch scripts for processing shotgun metagenomic data on the AWI HPC cluster. The pipeline consists of two steps:

---

## Step 1: Quality Control and Preprocessing (`1_step_shop_with_clumpify_WeddelseaPS97.sl`)

**Functionality:**
- `fastqc`: Perform quality control on raw reads (before and after filtering)
- `clumpify`: Optional deduplication (can be disabled)
- `fastp`: Read filtering, trimming, merging, and quality reporting

**Input:**
- Paired-end FastQ files (`.R1.fastq.gz`, `.R2.fastq.gz`) in the specified input directory (`INDIR`)

**Output:**
- Quality control reports (`out.fastqc_1`)
- Deduplicated files (`out.dedup_1`, if enabled)
- Filtered and merged reads (`out.fastp_1`)

**Execution:**
- Uses a SLURM array job on the `smp_new` partition
- Processes multiple samples in parallel

---

## Step 2: Taxonomic Classification (`2_step_shop_nt08_WeddelseaPS97.sl`)

**Functionality:**
- `kraken2`: Taxonomic classification using a custom NT database
- `krona`: Visualization of taxonomic results in interactive HTML format

**Input:**
- Filtered FastQ files from Step 1 (`out.fastp_1`)

**Output:**
- Kraken2 classification output and reports (`out.kraken2`)
- Krona plots (`out.krona`)

## Merging Kraken2 Reports into a TXT File

To combine all Kraken2 report files with a confidence threshold of 0.8 into a single tab-delimited file, run the following command:

```bash
awk 'BEGIN{FS=OFS="\t"} {print FILENAME, $0}' *0.8*report | awk 'BEGIN{FS=OFS="\t"} {gsub(/^[ \t]+/, "", $7)}1' > AntarcticaPS97_nt35_0.8.txt
```

**Execution:**
- Runs sequentially on a single `fat` node

---

## Requirements

Both scripts require the following modules to be available on the cluster:

- `fastqc/0.11.9`
- `bbmap/38.87`
- `fastp/0.20.1`
- `kraken2/2.1.2`
- `krona/2.7.1`

The Kraken2 database path in `step2.sh` may need to be adapted:
```bash
DB="/home/ollie/projects/bio/db/kraken2/nt_2021_04_db"


