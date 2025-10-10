#! /bin/bash

export JOB1="04A_quast-lsf"
export JOB2="04B_checkm-lsf"

# JOB1: first job - no dependencies
bsub -J $JOB1 < ${JOB1}.sh

# JOB2 depends on JOB1
bsub -J $JOB2 -w 'done($JOB1)' < ${JOB2}.sh

