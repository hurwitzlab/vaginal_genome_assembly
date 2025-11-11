#!/bin/bash
# --------------------------------------------------
# Request resources here
# --------------------------------------------------         
#SBATCH --job-name=trimmomatic          # job name
#SBATCH --ntasks=1                      # number of CPUs required 
#SBATCH --cpus-per-task=4               # number of CPU cores per task 
#SBATCH --nodes=1                       # number of nodes
#SBATCH --mem-per-cpu=8000              # memory per CPU core in MB (see also --mem) 
#SBATCH --time=10:00:00                 # time limit hrs:min:sec
#SBATCH --partition=standard            # partition name (i.e. standard, windfall)
#SBATCH --account=your_account          # account name (name of your group)                     
#SBATCH --output=process-%j.out         # standard output file name (%j expands to jobID)
#SBATCH --error=process-%j.err          # standard error file name (%j expands to jobID)
# --------------------------------------------------
# Load modules here
# --------------------------------------------------

# --------------------------------------------------
# Execute commands here
# --------------------------------------------------

# echo for log
echo "job started"; pwd; hostname; date

# source config gile and get sample name from input list based on job array index
source ./config.sh
export SAMPLE=`head -n +${SLURM_ARRAY_TASK_ID} $IN_LIST | tail -n 1`

# make the output directories 
TRIM_DIR="${WORK_DIR}/trimmed_reads"
UNPAIR_DIR="${WORK_DIR}/unpaired_reads"

echo "Running Trimmomatic on sample $SAMPLE"
apptainer run ${TRIMMOMATIC} trimmomatic PE -phred33 -threads 4 \
    ${FASTQ_DIR}/${SAMPLE}_R1_001.fastq.gz ${FASTQ_DIR}/${SAMPLE}_R2_001.fastq.gz \
    ${TRIM_DIR}/${SAMPLE}_R1_001.fastq.gz ${UNPAIR_DIR}/${SAMPLE}_R1_001.fastq.gz \
    ${TRIM_DIR}/${SAMPLE}_R2_001.fastq.gz ${UNPAIR_DIR}/${SAMPLE}_R2_001.fastq.gz \
    ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:100 HEADCROP:15

# print date for log
echo "job ended"; date