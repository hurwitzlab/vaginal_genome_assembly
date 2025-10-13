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
echo "launching ${JOB1}.lsf as a job."
JOB_ID=`bsub -J "$JOB1[1-$NUM_JOB]" < ${JOB1}.lsf`

echo "launching ${JOB2}.lsf as a job."
JOB_ID=`bsub -J "$JOB2[1-$NUM_JOB]" -w 'done($JOB1)' < ${JOB2}.lsf`


echo "launching ${JOB3}.lsf as a job."
JOB_ID=`bsub -J "$JOB3[1-$NUM_JOB]" -w 'done($JOB2)' < ${JOB3}.lsf`