#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1             
#SBATCH --time=12:00:00   
#SBATCH --partition=standard
#SBATCH --account=your_account
#SBATCH --array=0-15                         
#SBATCH --output=04A_quast-%a.out
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=5G                                    

pwd; hostname; date

source ./config.sh
names=($(cat $DATA_DIR/$ACCESSIONS))

SAMPLE_ID=${names[${SLURM_ARRAY_TASK_ID}]}

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
apptainer run ${QUAST} quast -t 24         -o $OUTDIR/${SAMPLE_ID}         -m 500         $CONTIGS
