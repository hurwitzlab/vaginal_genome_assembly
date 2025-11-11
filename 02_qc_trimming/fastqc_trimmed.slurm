#!/bin/bash
# --------------------------------------------------
# Request resources here
# --------------------------------------------------
#SBATCH --job-name=fastqc_trimmed       # job name
#SBATCH --ntasks=1                      # number of CPUs required 
#SBATCH --cpus-per-task=1               # number of CPU cores per task 
#SBATCH --nodes=1                       # number of nodes
#SBATCH --mem-per-cpu=4000              # memory per CPU core in MB (see also --mem) 
#SBATCH --time=10:00:00                 # time limit hrs:min:sec
#SBATCH --partition=standard            # partition name (i.e. standard, windfall)
#SBATCH --account=your_account          # account name (name of your group)                     
#SBATCH --output=process-%j.out         # standard output file name (%j expands to jobID)
#SBATCH --error=process-%j.err          # standard error file name (%j expands to jobID)                         

# --------------------------------------------------
# Load modules here
# --------------------------------------------------

# --------------------------------------------------
# Execute commands here
# --------------------------------------------------

# echo for log
echo "job started"; pwd; hostname; date

# source config gile and get sample name from input list based on job array index
source ./config.sh
export SAMPLE=`head -n +${SLURM_ARRAY_TASK_ID} $IN_LIST | tail -n 1`

# run FastQC
echo "Running FastQC on sample $SAMPLE"
apptainer run ${FASTQC} fastqc ${WORK_DIR}/trimmed_reads/${SAMPLE}_*.fastq*

# move FastQC results to a separate directory and copy to local directory for viewing
# create directory if it does not exist
TRIM_DIR="${WORK_DIR}/after_qc_trimming"
if [[ ! -d "$TRIM_DIR" ]]; then
  echo "$TRIM_DIR does not exist. Directory created"
  mkdir -p $TRIM_DIR
fi

#  move files
mv ${WORK_DIR}/trimmed_reads/${SAMPLE}_*_fastqc.html $TRIM_DIR
mv ${WORK_DIR}/trimmed_reads/${SAMPLE}_*_fastqc.zip $TRIM_DIR
cp -r $TRIM_DIR ~/01_qc_trimming

# print date for log
echo "job ended"; date