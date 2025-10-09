# Vaginal Genome Assembly Pipeline

A Snakemake workflow for assembly and quality control of vaginal genomes from Dr. Melissa Herbst-Kralovetz.

## Overview

This pipeline processes paired-end sequencing reads through the following steps:

1. **Quality Trimming** - Uses Trimmomatic to improve read quality by removing adapters and low-quality bases
2. **Quality Assessment** - Runs FastQC to assess the final quality of trimmed reads
3. **Human Read Filtering** - Uses Kraken2 to filter out human contamination reads
4. **Genome Assembly** - Assembles filtered reads into genomes using Unicycler
5. **Quality Checks** - Performs assembly quality assessment using:
   - checkM for completeness and contamination
   - Quast for assembly statistics

## Requirements

- [Conda](https://docs.conda.io/en/latest/miniconda.html) or [Mamba](https://mamba.readthedocs.io/)
- A Kraken2 database (for human read filtering)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/hurwitzlab/vaginal_genome_assembly.git
cd vaginal_genome_assembly
```

2. Create the conda environment:
```bash
conda env create -f environment.yaml
# Or with mamba (faster):
# mamba env create -f environment.yaml
```

3. Activate the environment:
```bash
conda activate vaginal_genome_assembly
```

## Setup

### 1. Prepare Input Data

Place your paired-end FASTQ files in the `data/` directory with the naming convention:
```
data/
  ├── sample1_R1.fastq.gz
  ├── sample1_R2.fastq.gz
  ├── sample2_R1.fastq.gz
  └── sample2_R2.fastq.gz
```

### 2. Download Adapter Sequences

Download Trimmomatic adapter sequences:
```bash
mkdir -p adapters
wget -P adapters https://raw.githubusercontent.com/timflutre/trimmomatic/master/adapters/TruSeq3-PE.fa
```

### 3. Configure the Pipeline

Edit `config.yaml` to:
- List your sample names (without _R1/_R2 suffix)
- Adjust Trimmomatic parameters if needed
- Set the path to your Kraken2 database

Example `config.yaml`:
```yaml
samples:
  - sample1
  - sample2

trimmomatic:
  adapters: "adapters/TruSeq3-PE.fa"
  leading: 3
  trailing: 3
  slidingwindow: "4:15"
  minlen: 36

kraken2:
  database: "/path/to/kraken2/database"
```

### 4. Kraken2 Database

You need a Kraken2 database for human read filtering. You can either:

**Option 1: Download a standard database**
```bash
# Download the standard database (requires ~50 GB)
kraken2-build --standard --db /path/to/kraken2/database
```

**Option 2: Build a human-only database**
```bash
# Download human genome for filtering
kraken2-build --download-library human --db /path/to/kraken2/database
kraken2-build --build --db /path/to/kraken2/database
```

Update the database path in `config.yaml`.

## Usage

### Run the entire pipeline

```bash
# Dry run to see what will be executed
snakemake --dry-run

# Run the pipeline (adjust cores as needed)
snakemake --cores 8

# Run with conda (if tools are not installed)
snakemake --use-conda --cores 8
```

### Run specific steps

```bash
# Only run trimming
snakemake --cores 4 results/trimmomatic/sample1_R1_paired.fastq.gz

# Only run FastQC
snakemake --cores 4 results/fastqc/sample1_R1_paired_fastqc.html

# Only run assembly for one sample
snakemake --cores 8 results/unicycler/sample1/assembly.fasta
```

## Output Structure

```
results/
├── trimmomatic/          # Trimmed reads
│   ├── sample1_R1_paired.fastq.gz
│   ├── sample1_R2_paired.fastq.gz
│   └── ...
├── fastqc/              # Quality control reports
│   ├── sample1_R1_paired_fastqc.html
│   └── ...
├── kraken2/             # Human-filtered reads
│   ├── sample1_R1_filtered.fastq
│   ├── sample1_R2_filtered.fastq
│   ├── sample1_report.txt
│   └── ...
├── unicycler/           # Assembled genomes
│   ├── sample1/
│   │   ├── assembly.fasta
│   │   ├── assembly.gfa
│   │   └── unicycler.log
│   └── ...
├── checkm/              # Completeness and contamination
│   ├── sample1/
│   │   └── checkm_results.txt
│   └── ...
└── quast/               # Assembly statistics
    ├── sample1/
    │   ├── report.html
    │   └── report.txt
    └── ...
```

## Citation

If you use this pipeline, please cite the tools it uses:

- **Trimmomatic**: Bolger, A. M., Lohse, M., & Usadel, B. (2014). Trimmomatic: a flexible trimmer for Illumina sequence data. Bioinformatics, 30(15), 2114-2120.
- **FastQC**: Andrews, S. (2010). FastQC: a quality control tool for high throughput sequence data.
- **Kraken2**: Wood, D. E., Lu, J., & Langmead, B. (2019). Improved metagenomic analysis with Kraken 2. Genome biology, 20(1), 1-13.
- **Unicycler**: Wick, R. R., Judd, L. M., Gorrie, C. L., & Holt, K. E. (2017). Unicycler: resolving bacterial genome assemblies from short and long sequencing reads. PLoS computational biology, 13(6), e1005595.
- **checkM**: Parks, D. H., Imelfort, M., Skennerton, C. T., Hugenholtz, P., & Tyson, G. W. (2015). CheckM: assessing the quality of microbial genomes recovered from isolates, single cells, and metagenomes. Genome research, 25(7), 1043-1055.
- **Quast**: Gurevich, A., Saveliev, V., Vyahhi, N., & Tesler, G. (2013). QUAST: quality assessment tool for genome assemblies. Bioinformatics, 29(8), 1072-1075.

## License

MIT License - see [LICENSE](LICENSE) file for details.
