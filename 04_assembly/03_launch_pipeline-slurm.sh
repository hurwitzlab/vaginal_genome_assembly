#! /bin/bash

# 03_assembly: first job - no dependencies
job1=$(sbatch 03_assembly.sh)
jid1=$(echo $job1 | sed 's/^Submitted batch job //')
echo $jid1

