# Shotgun Pipeline Step 2 – Taxonomic Classification with Kraken2 and Krona

This SLURM batch script (`2_step_shop_nt08_WeddelseaPS97.sl`) executes the second step of a shotgun metagenomic analysis pipeline. It performs taxonomic classification on multiple samples using [Kraken2](https://ccb.jhu.edu/software/kraken2/) and generates interactive Krona plots for visualization.

## Author
**Lars Harms**  
Contact: [lars.harms@awi.de](mailto:lars.harms@awi.de)

Adapted and used by: **Josefine Friederike Weiss**  
Contact: [Josefine-Friederike.Weiss@awi.de](mailto:Josefine-Friederike.Weiss@awi.de)

---

## SLURM Configuration

```bash
#SBATCH --job-name=step2_StBBering
#SBATCH --partition=fat
#SBATCH --time=12:00:00
#SBATCH --qos=normal
#SBATCH --cpus-per-task=36
#SBATCH --mail-type=END
#SBATCH --mail-user=Josefine-Friederike.Weiss@awi.de
```

## Required Variables to Set

Update the following variables as needed:

```bash
DB="/home/ollie/projects/bio/db/kraken2/nt_2021_04_db"  # Path to Kraken2 database
CONFIDENCE="0.8"  # Confidence threshold
```

## Given Variables (Do Not Modify)

These are set automatically by the script:

```bash
OUTDIR="output"
OUT_FASTP="out.fastp"
OUT_KRAKEN="out.kraken2"
OUT_KRONA="out.krona"
```

## Output Structure

The script creates:

```
output/
├── out.kraken2/         # Kraken2 output and report files
├── out.krona/           # Krona HTML plots
└── out.fastp/           # Input folder containing fastp-processed reads
```

## Modules Required

- `kraken2/2.1.2`
- `krona/2.7.1`

Make sure these modules are available and correctly loaded in your environment.

## Script Tasks

1. **Kraken2**:  
   - Runs classification on merged and paired reads.
   - Generates `.kraken` and `.report` files.

2. **Krona**:  
   - Creates one HTML plot per `.kraken` file.
   - Combines all plots into a `KRONA_plots_combined.html` summary.

## Example Output Files

```
output/out.kraken2/
├── SAMPLE_conf0.8_merged.kraken
├── SAMPLE_conf0.8_merged.kraken.report
├── SAMPLE_conf0.8_paired.kraken
├── SAMPLE_conf0.8_paired.kraken.report

output/out.krona/
├── SAMPLE_conf0.8_merged.html
├── SAMPLE_conf0.8_paired.html
└── KRONA_plots_combined.html
```

---

## Notes

- Ensure that the fastp output folder (`out.fastp`) exists and contains merged and paired `.fq.gz` files.
- This script assumes all samples are processed in the same way and share common filename endings.
