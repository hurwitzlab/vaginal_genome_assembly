#!/bin/bash
#SBATCH --output=03_assembly-%a.out
#SBATCH --account=your_account
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=48:00:00
#SBATCH --cpus-per-task=28
#SBATCH --mem-per-cpu=5gb
#SBATCH --array=0-15

pwd; hostname; date

source ./config.sh
names=($(cat $DATA_DIR/$ACCESSIONS))

SAMPLE_ID=${names[${SLURM_ARRAY_TASK_ID}]}

NO_HUMAN=${FASTQ_DIR}/out_reads_taxonomy/${SAMPLE_ID}/nonhuman_reads
PAIR1=${NO_HUMAN}/r1.fq.gz
PAIR2=${NO_HUMAN}/r2.fq.gz

#add threads flag & exposition on adding threads or it runs inefficient
apptainer run ${UNICYCLER} unicycler -1 ${PAIR1} -2 ${PAIR2} -o ${OUT_UNI}/${names[${SLURM_ARRAY_TASK_ID}]} --threads 28

