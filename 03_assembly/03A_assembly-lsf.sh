#!/bin/bash
#BSUB -J 03A_assembly-lsf[1-15]%15  # job name, with array number to run in parallel
#BSUB -n 28                         # number of CPUs required per task
#BSUB -q shared_memory              # the queue to run on
#BSUB -R "span[hosts=1]"            # number of hosts to spread the jobs across, 1 host used here
#BSUB -R "rusage[mem=140GB]"        # required total memory for the job 
#BSUB -o "./output.%J_%I.log"       # standard output file (%J is job name, %I is the array number)
#BSUB -e "./error.%J_%I.log"        # standard error file (%J is job ID, %I is the array number)
#BSUB -W 48:00                      # time to run


pwd; hostname; date

source ./config.sh
names=($(cat $DATA_DIR/$ACCESSIONS))
JOBINDEX=$(($LSB_JOBINDEX - 1))
SAMPLE_ID=${names[${JOBINDEX}]}

NO_HUMAN=${FASTQ_DIR}/out_reads_taxonomy/${SAMPLE_ID}/nonhuman_reads
PAIR1=${NO_HUMAN}/r1.fq.gz
PAIR2=${NO_HUMAN}/r2.fq.gz

#add threads flag & exposition on adding threads or it runs inefficient
apptainer run ${UNICYCLER} unicycler -1 ${PAIR1} -2 ${PAIR2} -o ${OUT_UNI}/${names[${JOBINDEX}]} --threads ${LSB_DJOB_NUMPROC}

