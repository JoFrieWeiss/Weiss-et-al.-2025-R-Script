# Shotgun Pipeline Step 1 – SLURM Batch Script

This repository contains a SLURM batch script (`1_step_shop_with_clumpify_WeddelseaPS97.sl`) to run the first preprocessing step of a shotgun metagenomic sequencing pipeline for multiple samples using SLURM array jobs. It includes quality control, optional deduplication, filtering, merging, and final QC.

---
## Author & Contact

- **Lars Harms** – Author of the original script  
 [lars.harms@awi.de](mailto:lars.harms@awi.de)

- **Josefine Friederike Weiss** – Adapted and applied for Antarctic metagenomics  
  [Josefine-Friederike.Weiss@awi.de](mailto:Josefine-Friederike.Weiss@awi.de)

---
## What This Script Does

For each pair of R1/R2 `.fastq.gz` files, the script performs:

1. **Initial FASTQC**: Runs `fastqc` before any processing.
2. **Deduplication (optional)**: Uses `clumpify.sh` to remove PCR duplicates.
3. **Read filtering and merging**: Runs `fastp` for adapter trimming, filtering, merging, and quality filtering.
4. **Final FASTQC**: Evaluates quality after preprocessing.

---

## How to Use

### 1. Adjust Parameters

In the script section labeled `# set required variables`, change the paths and settings to match your environment:

```bash
INDIR=/path/to/your/fastq/files
R1_ENDING=".R1.fastq.gz"
R2_ENDING=".R2.fastq.gz"
DEDUP="TRUE"  # Set to FALSE to disable deduplication
FILTER="--low_complexity_filter"  # Optional FASTP argument
```

Make sure your input directory contains matching paired-end files (`*_R1.fastq.gz` and `*_R2.fastq.gz`).

### 2. Submit the Job

Use `sbatch` to submit the job to your SLURM scheduler:

```bash
sbatch step1.sh
```

---

## SLURM Configuration

These SLURM settings are defined at the top of the script:

```bash
#SBATCH --job-name=step1
#SBATCH --partition=smp_new
#SBATCH --time=60:00:00
#SBATCH --qos=large
#SBATCH --array=1-37%5             # Modify array range to match number of samples
#SBATCH --cpus-per-task=36
#SBATCH --mem=62G
#SBATCH --mail-type=END
#SBATCH --mail-user=Josefine-Friederike.Weiss@awi.de
```

> **Note**: The array job setup runs each sample in parallel. `%5` limits concurrent jobs to 5.

---

## Output Structure

Results are stored in the `output_1` folder:

```
output_1/
├── out.fastqc_1/
│   ├── pre/        # FASTQC before processing
│   └── post/       # FASTQC after processing
├── out.dedup_1/    # Deduplicated reads (if enabled)
└── out.fastp_1/    # Trimmed, filtered, merged reads + FASTP reports
```

---

## Tools Used

The following tools are used and loaded as modules (as on AWI's HPC cluster):

| Tool      | Version   | Description                       |
|-----------|-----------|-----------------------------------|
| **FASTQC**    | 0.11.9    | Quality control of FASTQ files |
| **BBTools**   | 38.87     | `clumpify.sh` for deduplication |
| **FASTP**     | 0.20.1    | Adapter trimming, merging, filtering |

All modules must be available via your environment's `module load` system.

---

## Script Example

You can find the full batch script in `step1.sh`. Here's a minimal snippet of the logic:

```bash
# Load module
module load bio/fastqc
# Run QC on input files
srun fastqc -q -o ${OUTDIR}/${OUT_FQC}/pre -t 2 ${INDIR}/${FILE_R1} ${INDIR}/${FILE_R2}
module unload bio/fastqc
```

Full logic for deduplication and fastp trimming/merging is handled conditionally.

---

## License

This script is provided as-is, without warranty. You may freely use, adapt, and share it for research purposes. Please acknowledge appropriately in publications or derivative scripts.

---

## Example Submit Command

```bash
sbatch step1.sh
```

Make sure the number of samples in your `INDIR` matches the SLURM array range (`--array=1-N`), and that file endings (e.g. `.R1.fastq.gz`) are correctly specified.

---
