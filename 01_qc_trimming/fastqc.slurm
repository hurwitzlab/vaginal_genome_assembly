#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1             
#SBATCH --time=10:00:00   
#SBATCH --partition=standard
#SBATCH --account=your_account
#SBATCH --array=0-15                      
#SBATCH --output=01A_fastqc-%a.out
#SBATCH --cpus-per-task=1                  
#SBATCH --mem=4G                           

pwd; hostname; date

source ./config.sh
names=($(cat $FASTQ_DIR/$ACCESSIONS))

apptainer run ${FASTQC} fastqc $FASTQ_DIR/${names[${SLURM_ARRAY_TASK_ID}]}_*.fastq*

TRIM_DIR="${WORK_DIR}/before_qc_trimming"
if [[ ! -d "$TRIM_DIR" ]]; then
  echo "$TRIM_DIR does not exist. Directory created"
  mkdir -p $TRIM_DIR
fi

mv $FASTQ_DIR/${names[${SLURM_ARRAY_TASK_ID}]}_*_fastqc.html $TRIM_DIR
mv $FASTQ_DIR/${names[${SLURM_ARRAY_TASK_ID}]}_*_fastqc.zip $TRIM_DIR
cp -r $TRIM_DIR ~/01_qc_trimming
 
