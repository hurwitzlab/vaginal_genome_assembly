#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1             
#SBATCH --time=10:00:00   
#SBATCH --partition=standard
#SBATCH --account=your_account
#SBATCH --array=0-15
#SBATCH --output=01B_trim-%a.out
#SBATCH --cpus-per-task=4                   
#SBATCH --mem=8G                 
 
pwd; hostname; date
source ./config.sh
names=($(cat ${FASTQ_DIR}/${XFILE}))

TRIM_DIR="${WORK_DIR}/trimmed_reads"
UNPAIR_DIR="${WORK_DIR}/unpaired_reads"

apptainer run ${TRIMMOMATIC} trimmomatic PE -phred33 -threads 4     ${FASTQ_DIR}/${names[${SLURM_ARRAY_TASK_ID}]}_R1_001.fastq.gz ${FASTQ_DIR}/${names[${SLURM_ARRAY_TASK_ID}]}_R2_001.fastq.gz     ${TRIM_DIR}/${names[${SLURM_ARRAY_TASK_ID}]}_R1_001.fastq.gz ${UNPAIR_DIR}/${names[${SLURM_ARRAY_TASK_ID}]}_R1_001.fastq.gz     ${TRIM_DIR}/${names[${SLURM_ARRAY_TASK_ID}]}_R2_001.fastq.gz ${UNPAIR_DIR}/${names[${SLURM_ARRAY_TASK_ID}]}_R2_001.fastq.gz     ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:100 HEADCROP:15
