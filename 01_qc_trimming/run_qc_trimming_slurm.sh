#! /bin/bash
# This script submits a series of job arrays to an LSF scheduler
# Each job array corresponds to a step in the QC and trimming process
# The steps are:
# 1. FastQC on raw reads
# 2. Trimmomatic for trimming reads
# 3. FastQC on trimmed reads    
# Each job array will process multiple samples in parallel
# The number of samples is determined by the number of lines in the input list file     
# --------------------------------------------------


# load job configuration
source ./config.sh


# make sure sample file is in the right place
if [[ ! -f "$IN_LIST" ]]; then
    echo "$IN_LIST does not exist. Please provide the path for a list of datasets to process. Job terminated."
    exit 1
fi

export JOB1="fastqc"
export JOB2="trimmomatic"
export JOB3="fastqc_trimmed"

# get number of samples to process
# the number of samples will be used to set the range of the job array
export NUM_JOB=$(wc -l < "$IN_LIST")

# submit job arrays for each step
echo "launching ${JOB1}.slurm as a job."
JOB_ID=`sbatch --job-name $JOB1 -a 1-$NUM_JOB ${JOB1}.slurm`
jid1=$(echo $JOB1 | sed 's/^Submitted batch job //')
echo $jid1

echo "launching ${JOB2}.slurm as a job."
JOB_ID=`sbatch --dependency=afterok:$jid1 --job-name $JOB2 -a 1-$NUM_JOB ${JOB2}.slurm`     # depends on successful completion of JOB1
jid2=$(echo $JOB2 | sed 's/^Submitted batch job //')
echo $jid2

echo "launching ${JOB3}.slurm as a job."
JOB_ID=`sbatch --dependency=afterok:$jid2 --job-name $JOB3 -a 1-$NUM_JOB ${JOB3}.slurm`     # depends on successful completion of JOB2
jid3=$(echo $JOB3 | sed 's/^Submitted batch job //')
echo $jid3


