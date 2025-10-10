#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1             
#SBATCH --time=24:00:00   
#SBATCH --partition=standard
#SBATCH --account=your_account
#SBATCH --array=0-15                      
#SBATCH --output=04B_checkm-%a.out
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=5G                                    

pwd; hostname; date

source ./config.sh
names=($(cat $DATA_DIR/$ACCESSIONS))

SAMPLE_ID=${names[${SLURM_ARRAY_TASK_ID}]}

### create output directory for the report
OUTDIR=${WORK_DIR}/out_checkm

### create the outdirs if they do not exist
if [[ ! -d "$CHECKM_OUTDIR" ]]; then
  echo "$CHECKM_OUTDIR does not exist. Directory created"
  mkdir -p $CHECKM_OUTDIR
fi

### Run checkm
apptainer run ${CHECKM} checkm2         predict --threads ${SLURM_CPUS_PER_TASK}         --input $UNICYCLER_DIR         -x fasta         --output-directory $OUTDIR/${SAMPLE_ID}         --database_path /groups/bhurwitz/databases/checkm2_database/uniref100.KO.1.dmnd  
