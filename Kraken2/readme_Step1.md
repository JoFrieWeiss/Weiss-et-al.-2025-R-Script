# Shotgun Pipeline Step 1 – SLURM Batch Script

This repository contains a SLURM batch script (`step1.sh`) that performs the first preprocessing step of a shotgun metagenomic sequencing pipeline for multiple samples using array jobs. It supports deduplication, read filtering, merging, and quality control.

---

## Pipeline Summary

The script performs the following steps for each paired-end `.fastq.gz` file:

1. **FASTQC (Pre-trimming)**
2. **Clumpify (optional deduplication)**
3. **FASTP (adapter trimming, filtering, merging)**
4. **FASTQC (Post-trimming)**

---

## How to Run

### 1. Modify Script Parameters

Edit the section marked `# set required variables`:

```bash
INDIR=/path/to/your/fastq/files
R1_ENDING=".R1.fastq.gz"
R2_ENDING=".R2.fastq.gz"
DEDUP="TRUE"  # Set to FALSE to skip deduplication
FILTER="--low_complexity_filter"  # Or leave empty ""

Make sure your input directory contains matching paired-end files (*_R1.fastq.gz and *_R2.fastq.gz).

2. Submit the Job
Use sbatch to submit the job to your SLURM scheduler:

sbatch step1.sh

#SBATCH --job-name=step1
#SBATCH --partition=smp_new
#SBATCH --time=60:00:00
#SBATCH --qos=large
#SBATCH --array=1-37%5             # Modify array range to match number of samples
#SBATCH --cpus-per-task=36
#SBATCH --mem=62G
#SBATCH --mail-type=END
#SBATCH --mail-user= XXXX

Output Structure

Results are stored in the output_1 folder:

output_1/
├── out.fastqc_1/
│   ├── pre/        # FASTQC before processing
│   └── post/       # FASTQC after processing
├── out.dedup_1/    # Deduplicated reads (if enabled)
└── out.fastp_1/    # Trimmed, filtered, merged reads + FASTP reports

