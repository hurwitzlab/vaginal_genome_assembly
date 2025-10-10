#!/bin/bash
#BSUB -J 04A_quast-lsf[1-15]%15     # job name, with array number to run in parallel
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

### create output directories for the reports
### note that we are going to compare both assemblies at once
OUTDIR=${WORK_DIR}/out_quast

### create the outdir if it does not exist
if [[ ! -d "$OUTDIR" ]]; then
  echo "$OUTDIR does not exist. Directory created"
  mkdir $OUTDIR
fi

### Contigs to use
CONTIGS=$UNICYCLER_DIR/${SAMPLE_ID}/assembly.fasta

### Run Quast
apptainer run ${QUAST} quast -t ${LSB_DJOB_NUMPROC}         -o $OUTDIR/${SAMPLE_ID}         -m 500         $CONTIGS
