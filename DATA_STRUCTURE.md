# Example Data Structure

This document describes the expected directory structure and naming conventions for running the vaginal genome assembly pipeline.

## Input Data Structure

```
vaginal_genome_assembly/
├── data/                           # Place your raw sequencing reads here
│   ├── sample1_R1.fastq.gz        # Forward reads for sample1
│   ├── sample1_R2.fastq.gz        # Reverse reads for sample1
│   ├── sample2_R1.fastq.gz        # Forward reads for sample2
│   └── sample2_R2.fastq.gz        # Reverse reads for sample2
│
├── adapters/                       # Adapter sequences for Trimmomatic
│   └── TruSeq3-PE.fa              # Download from Trimmomatic repository
│
├── config.yaml                     # Pipeline configuration
├── Snakefile                       # Workflow definition
└── environment.yaml                # Conda environment specification
```

## Naming Convention

### Input Files
- Forward reads: `{sample}_R1.fastq.gz`
- Reverse reads: `{sample}_R2.fastq.gz`

Where `{sample}` is a unique identifier for each sample (e.g., sample1, sample2, SRR12345, etc.)

### Output Structure

After running the pipeline, the following directory structure will be created:

```
results/
├── trimmomatic/                    # Quality trimmed reads
│   ├── sample1_R1_paired.fastq.gz
│   ├── sample1_R1_unpaired.fastq.gz
│   ├── sample1_R2_paired.fastq.gz
│   ├── sample1_R2_unpaired.fastq.gz
│   └── ...
│
├── fastqc/                         # Quality control reports
│   ├── sample1_R1_paired_fastqc.html
│   ├── sample1_R1_paired_fastqc.zip
│   ├── sample1_R2_paired_fastqc.html
│   ├── sample1_R2_paired_fastqc.zip
│   └── ...
│
├── kraken2/                        # Human-filtered reads and reports
│   ├── sample1_R1_filtered.fastq
│   ├── sample1_R2_filtered.fastq
│   ├── sample1_report.txt
│   ├── sample1_classified.txt
│   └── ...
│
├── unicycler/                      # Genome assemblies
│   ├── sample1/
│   │   ├── assembly.fasta          # Main assembly output
│   │   ├── assembly.gfa            # Assembly graph
│   │   └── unicycler.log           # Assembly log
│   ├── sample2/
│   └── ...
│
├── checkm/                         # Assembly quality metrics
│   ├── sample1/
│   │   └── checkm_results.txt      # Completeness and contamination
│   ├── sample2/
│   └── ...
│
└── quast/                          # Assembly statistics
    ├── sample1/
    │   ├── report.html             # HTML report
    │   └── report.txt              # Text report
    ├── sample2/
    └── ...
```

## Logs

Log files for each step are stored in the `logs/` directory:

```
logs/
├── trimmomatic/
│   ├── sample1.log
│   └── sample2.log
├── fastqc/
│   ├── sample1.log
│   └── sample2.log
├── kraken2/
│   ├── sample1.log
│   └── sample2.log
├── unicycler/
│   ├── sample1.log
│   └── sample2.log
├── checkm/
│   ├── sample1.log
│   └── sample2.log
└── quast/
    ├── sample1.log
    └── sample2.log
```

## Configuration Example

Update the `config.yaml` file to list your samples:

```yaml
samples:
  - sample1
  - sample2
  - sample3

trimmomatic:
  adapters: "adapters/TruSeq3-PE.fa"
  leading: 3
  trailing: 3
  slidingwindow: "4:15"
  minlen: 36

kraken2:
  database: "/path/to/kraken2/database"
```

## Important Notes

1. **Sample names**: Must match between the file names and the config.yaml file
2. **File extensions**: Input files must be gzipped (.fastq.gz)
3. **Paired reads**: Both R1 and R2 files must exist for each sample
4. **Database**: Ensure the Kraken2 database path in config.yaml is correct
