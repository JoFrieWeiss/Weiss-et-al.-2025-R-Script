#!/bin/bash

#===========================================================================
# slurm batch script to run the shotgun pipeline step 2
# on several sample sequentially on a fat node
# Version 0.4 
#
# by Lars Harms
# 
# contact: lars.harms@awi.de
#
# slurm options and variables under >set required variables< 
# have to be modified by the user
#=============================================================================

#SBATCH --job-name=step2_StBBering
#SBATCH --partition=fat
#SBATCH --time=12:00:00
#SBATCH --qos=normal
#SBATCH --cpus-per-task=36
#SBATCH --mail-type=END
#SBATCH --mail-user=Josefine-Friederike.Weiss@awi.de

# set required variables (adapt according to your own requirements)
#===================================================================
#KRAKEN
DB="/home/ollie/projects/bio/db/kraken2/nt_2021_04_db"
CONFIDENCE="0.8"

# given variables (please do not change)
#===================================================================

WORK=${PWD}
OUTDIR="output"
OUT_FASTP="out.fastp"
OUT_KRAKEN="out.kraken2"
OUT_KRONA="out.krona"

KRAKEN2="kraken2/2.1.2"
KRONA="krona/2.7.1"

END_R1="_fastp_R1.fq.gz"
END_R2="_fastp_R2.fq.gz"
END_MERGED="_fastp_merged_R2.fq.gz"

CPU=${SLURM_CPUS_PER_TASK}

# prepare environment
#===================================================================
mkdir -p ${OUTDIR}/${OUT_KRAKEN}
mkdir -p ${OUTDIR}/${OUT_KRONA}

# tasks to be performed
#===================================================================

# KRAKEN2
#----------
module load bio/${KRAKEN2}
for fq in ${OUTDIR}/${OUT_FASTP}/*${END_MERGED} 
do 
	BASE=${fq##*/}
	ID=${BASE%${END_MERGED}}
	srun kraken2 --confidence ${CONFIDENCE} --db ${DB} ${fq} --threads ${CPU} --gzip-compressed --output ${OUTDIR}/${OUT_KRAKEN}/${ID}_conf${CONFIDENCE}_merged.kraken --report ${OUTDIR}/${OUT_KRAKEN}/${ID}_conf${CONFIDENCE}_merged.kraken.report
	srun kraken2 --confidence ${CONFIDENCE} --db ${DB} --paired ${OUTDIR}/${OUT_FASTP}/${ID}${END_R1} ${OUTDIR}/${OUT_FASTP}/${ID}${END_R2} --threads ${CPU} --gzip-compressed --output ${OUTDIR}/${OUT_KRAKEN}/${ID}_conf${CONFIDENCE}_paired.kraken --report ${OUTDIR}/${OUT_KRAKEN}/${ID}_conf${CONFIDENCE}_paired.kraken.report
done
module unload bio/${KRAKEN2}

# KRONA
#----------

module load bio/${KRONA}
for kraken in ${OUTDIR}/${OUT_KRAKEN}/*.kraken 
do 
	BASE=${kraken##*/}
	ID=${BASE%.kraken}
	srun ktImportTaxonomy -q 2 -t 3 ${kraken} -o ${OUTDIR}/${OUT_KRONA}/${ID}.html
done

#srun ktImportTaxonomy -q 2 -t 3 ${OUTDIR}/${OUT_KRAKEN}/*_merged.kraken -o ${OUTDIR}/${OUT_KRONA}/KRONA_plots_merged_combined.html

#srun ktImportTaxonomy -q 2 -t 3 ${OUTDIR}/${OUT_KRAKEN}/*_paired.kraken -o ${OUTDIR}/${OUT_KRONA}/KRONA_plots_paired_combined.html

srun ktImportTaxonomy -q 2 -t 3 ${OUTDIR}/${OUT_KRAKEN}/*.kraken -o ${OUTDIR}/${OUT_KRONA}/KRONA_plots_combined.html

module unload bio/${KRONA}