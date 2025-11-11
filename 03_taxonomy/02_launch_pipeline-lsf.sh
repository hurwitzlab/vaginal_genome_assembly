#! /bin/bash

export JOB1="02A_taxonomy-lsf"

# JOB1: first job - no dependencies
bsub -J $JOB1 < ${JOB1}.sh

