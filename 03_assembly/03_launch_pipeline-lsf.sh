#! /bin/bash

export JOB1="03A_assembly-lsf"

# JOB1: first job - no dependencies
bsub -J $JOB1 < ${JOB1}.sh

