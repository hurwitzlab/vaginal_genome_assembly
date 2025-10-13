#! /bin/bash

# 01A_run_fastqc: first job - no dependencies
job1=$(sbatch 01A_run_fastqc.sh)
jid1=$(echo $job1 | sed 's/^Submitted batch job //')
echo $jid1

# 01B_run_trimmomatic: jid2 depends on jid1
job2=$(sbatch --dependency=afterok:$jid1 01B_run_trimmomatic.sh)
jid2=$(echo $job2 | sed 's/^Submitted batch job //')
echo $jid2

# 01C_run_fastqc: jid3 depends on jid2
job3=$(sbatch --dependency=afterok:$jid2 01C_run_fastqc.sh)
jid3=$(echo $job3 | sed 's/^Submitted batch job //')
echo $jid3

