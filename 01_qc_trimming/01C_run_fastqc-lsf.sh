#!/bin/bash
#BSUB -J 01C_run_fastqc-lsf[1-15]%15       # job name, with array number to run in parallel
#BSUB -n 2                                 # number of CPUs required per task
#BSUB -q shared_memory                     # the queue to run on
#BSUB -R "span[hosts=1]"                   # number of hosts to spread the jobs across, 1 host used here
#BSUB -R "rusage[mem=4GB]"                 # required total memory for the job 
#BSUB -o "./output.%J_%I.log"              # standard output file (%J is job name, %I is the array number)
#BSUB -e "./error.%J_%I.log"               # standard error file (%J is job ID, %I is the array number)
#BSUB -W 10:00                             # time to run

pwd; hostname; date

source ./config.sh
names=($(cat $FASTQ_DIR/$ACCESSIONS))

JOBINDEX=$(($LSB_JOBINDEX - 1))

apptainer run ${FASTQC} fastqc ${WORK_DIR}/trimmed_reads/${names[${JOBINDEX}]}_*.fastq*

TRIM_DIR="${WORK_DIR}/after_qc_trimming"
if [[ ! -d "$TRIM_DIR" ]]; then
  echo "$TRIM_DIR does not exist. Directory created"
  mkdir -p $TRIM_DIR
fi

mv ${WORK_DIR}/trimmed_reads/${names[${JOBINDEX}]}_*_fastqc.html $TRIM_DIR
mv ${WORK_DIR}/trimmed_reads/${names[${JOBINDEX}]}_*_fastqc.zip $TRIM_DIR
cp -r $TRIM_DIR ~/01_qc_trimming

