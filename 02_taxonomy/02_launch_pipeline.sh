#! /bin/bash

# 02A_taxonomy: jid1 has no dependencies
job1=$(sbatch 02A_taxonomy.sh)
jid1=$(echo $job1 | sed 's/^Submitted batch job //')
echo $jid1

