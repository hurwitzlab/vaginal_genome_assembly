#!/bin/bash
#BSUB -J 01B_run_trimmomatic-lsf[1-15]%15  # job name, with array number to run in parallel
#BSUB -n 2                                 # number of CPUs required per task
#BSUB -q shared_memory                     # the queue to run on
#BSUB -R "span[hosts=1]"                   # number of hosts to spread the jobs across, 1 host used here
#BSUB -R "rusage[mem=8GB]"                 # required total memory for the job 
#BSUB -o "./output.%J_%I.log"              # standard output file (%J is job name, %I is the array number)
#BSUB -e "./error.%J_%I.log"               # standard error file (%J is job ID, %I is the array number)
#BSUB -W 10:00                             # time to run

pwd; hostname; date
source ./config.sh
names=($(cat ${FASTQ_DIR}/${ACCESSIONS}))

JOBINDEX=$(($LSB_JOBINDEX - 1))

TRIM_DIR="${WORK_DIR}/trimmed_reads"
UNPAIR_DIR="${WORK_DIR}/unpaired_reads"

apptainer run ${TRIMMOMATIC} trimmomatic PE -phred33 -threads 4     ${FASTQ_DIR}/${names[${JOBINDEX}]}_R1_001.fastq.gz ${FASTQ_DIR}/${names[${JOBINDEX}]}_R2_001.fastq.gz     ${TRIM_DIR}/${names[${JOBINDEX}]}_R1_001.fastq.gz ${UNPAIR_DIR}/${names[${JOBINDEX}]}_R1_001.fastq.gz     ${TRIM_DIR}/${names[${JOBINDEX}]}_R2_001.fastq.gz ${UNPAIR_DIR}/${names[${JOBINDEX}]}_R2_001.fastq.gz     ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:100 HEADCROP:15
