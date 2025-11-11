#!/bin/bash
#BSUB -J 04B_checkm-lsf[1-15]%15    # job name, with array number to run in parallel
#BSUB -n 24                         # number of CPUs required per task
#BSUB -q shared_memory              # the queue to run on
#BSUB -R "span[hosts=1]"            # number of hosts to spread the jobs across, 1 host used here
#BSUB -R "rusage[mem=140GB]"        # required total memory for the job 
#BSUB -o "./output.%J_%I.log"       # standard output file (%J is job name, %I is the array number)
#BSUB -e "./error.%J_%I.log"        # standard error file (%J is job ID, %I is the array number)
#BSUB -W 12:00                      # time to run

pwd; hostname; date

source ./config.sh
names=($(cat $DATA_DIR/$ACCESSIONS))
JOBINDEX=$(($LSB_JOBINDEX - 1))
SAMPLE_ID=${names[${JOBINDEX}]}

### create output directory for the report
OUTDIR=${WORK_DIR}/out_checkm

### create the outdirs if they do not exist
if [[ ! -d "$CHECKM_OUTDIR" ]]; then
  echo "$CHECKM_OUTDIR does not exist. Directory created"
  mkdir -p $CHECKM_OUTDIR
fi

### Run checkm
apptainer run ${CHECKM} checkm2         predict --threads ${LSB_DJOB_NUMPROC}         --input $UNICYCLER_DIR         -x fasta         --output-directory $OUTDIR/${SAMPLE_ID}         --database_path /groups/bhurwitz/databases/checkm2_database/uniref100.KO.1.dmnd  
