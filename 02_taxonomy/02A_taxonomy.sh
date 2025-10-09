#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --nodes=1             
#SBATCH --time=10:00:00   
#SBATCH --partition=standard
#SBATCH --account=your_account
#SBATCH --array=0-15                         
#SBATCH --output=10A_read_taxonomy-%a.out
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=5G  

pwd; hostname; date

source $SLURM_SUBMIT_DIR/config.sh
names=($(cat $DATA_DIR/$ACCESSIONS))

SAMPLE_ID=${names[${SLURM_ARRAY_TASK_ID}]}

### reads with human removed to match to the reference database
PAIR1=${FASTQ_DIR}/${SAMPLE_ID}_R1_001.fastq.gz
PAIR2=${FASTQ_DIR}/${SAMPLE_ID}_R2_001.fastq.gz

KRAKEN_OUTDIR=${WORK_DIR}/out_reads_taxonomy
OUTDIR=${KRAKEN_OUTDIR}/${SAMPLE_ID}
HUMAN_READ_DIR=${OUTDIR}/human_reads
NONHUMAN_READ_DIR=${OUTDIR}/nonhuman_reads

### create the outdir if it does not exist
if [[ ! -d "$KRAKEN_OUTDIR" ]]; then
  echo "$KRAKEN_OUTDIR does not exist. Directory created"
  mkdir $KRAKEN_OUTDIR
fi

if [[ ! -d "$OUTDIR" ]]; then
  echo "$OUTDIR does not exist. Directory created"
  mkdir $OUTDIR
fi

if [[ ! -d "$HUMAN_READ_DIR" ]]; then
  echo "$HUMAN_READ_DIR does not exist. Directory created"
  mkdir $HUMAN_READ_DIR
fi

if [[ ! -d "$NONHUMAN_READ_DIR" ]]; then
  echo "$NONHUMAN_READ_DIR does not exist. Directory created"
  mkdir $NONHUMAN_READ_DIR
fi

# check input
echo ${PAIR1}
echo ${PAIR2}
echo ${OUTDIR}

apptainer run ${KRAKEN2} kraken2 --db ${DB_DIR} --paired   --classified-out ${OUTDIR}/cseqs#.fq --output ${OUTDIR}/kraken_results.txt   --report ${OUTDIR}/kraken_report.txt --use-names --threads ${SLURM_CPUS_PER_TASK}   ${PAIR1} ${PAIR2}

# refine hits with Bracken
REPORT="${OUTDIR}/kraken_report.txt"
RESULTS="${OUTDIR}/kraken_results.txt"
apptainer run ${BRACKEN} est_abundance.py -i ${REPORT} -o ${OUTDIR}/bracken_results.txt -k ${DB_DIR}/database${KMER_SIZE}mers.kmer_distrib

# get human and non-human reads (microbial)
TAXID=9606
HUMAN_R1="${HUMAN_READ_DIR}/r1.fq"
HUMAN_R2="${HUMAN_READ_DIR}/r2.fq"

BRACKEN_REPORT="${OUTDIR}/kraken_report_bracken_species.txt"
BRACKEN_RESULTS="${OUTDIR}/bracken_results.txt"

apptainer run ${KRAKENTOOLS} extract_kraken_reads.py -k ${RESULTS}  -r ${BRACKEN_REPORT} -s1 ${PAIR1} -s2 ${PAIR2} --taxid ${TAXID}  -o ${HUMAN_R1} -o2 ${HUMAN_R2} --include-children --fastq-output 

gzip ${HUMAN_READ_DIR}/r1.fq
gzip ${HUMAN_READ_DIR}/r2.fq

### selects all reads NOT from a given set of Kraken taxids (and all children)

NONHUMAN_R1="${NONHUMAN_READ_DIR}/r1.fq"
NONHUMAN_R2="${NONHUMAN_READ_DIR}/r2.fq"

apptainer run ${KRAKENTOOLS} extract_kraken_reads.py -k ${RESULTS}  -r ${BRACKEN_REPORT} -s1 ${PAIR1} -s2 ${PAIR2} --taxid ${TAXID}  -o ${NONHUMAN_R1} -o2 ${NONHUMAN_R2} --include-children  --exclude --fastq-output 

gzip ${NONHUMAN_READ_DIR}/r1.fq
gzip ${NONHUMAN_READ_DIR}/r2.fq

echo "Finished `date`"

