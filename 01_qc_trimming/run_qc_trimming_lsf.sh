#! /bin/bash

export JOB1="01A_run_fastqc-lsf"
export JOB2="01B_run_trimmomatic-lsf"
export JOB3="01C_run_fastqc-lsf"

# JOB1: first job - no dependencies
bsub -J $JOB1 < ${JOB1}.sh

# JOB2 depends on JOB1
bsub -J $JOB2 -w 'done($JOB1)' < ${JOB2}.sh

# JOB3 depends on JOB2
bsub -J $JOB3 -w 'done($JOB2)' < ${JOB3}.sh

