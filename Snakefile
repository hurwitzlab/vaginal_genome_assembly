"""
Snakemake workflow for vaginal genome assembly
This pipeline processes paired-end reads through quality control,
human read filtering, and genome assembly with quality checks.
"""

configfile: "config.yaml"

# Define samples from config
SAMPLES = config["samples"]

# Final output rule
rule all:
    input:
        # Trimmomatic outputs
        expand("results/trimmomatic/{sample}_R1_paired.fastq.gz", sample=SAMPLES),
        expand("results/trimmomatic/{sample}_R2_paired.fastq.gz", sample=SAMPLES),
        # FastQC outputs
        expand("results/fastqc/{sample}_R1_paired_fastqc.html", sample=SAMPLES),
        expand("results/fastqc/{sample}_R2_paired_fastqc.html", sample=SAMPLES),
        # Kraken2 outputs
        expand("results/kraken2/{sample}_R1_filtered.fastq", sample=SAMPLES),
        expand("results/kraken2/{sample}_R2_filtered.fastq", sample=SAMPLES),
        # Unicycler assembly outputs
        expand("results/unicycler/{sample}/assembly.fasta", sample=SAMPLES),
        # checkM outputs
        expand("results/checkm/{sample}/checkm_results.txt", sample=SAMPLES),
        # Quast outputs
        expand("results/quast/{sample}/report.html", sample=SAMPLES)

# Rule for quality trimming with Trimmomatic
rule trimmomatic:
    input:
        r1 = "data/{sample}_R1.fastq.gz",
        r2 = "data/{sample}_R2.fastq.gz"
    output:
        r1_paired = "results/trimmomatic/{sample}_R1_paired.fastq.gz",
        r1_unpaired = "results/trimmomatic/{sample}_R1_unpaired.fastq.gz",
        r2_paired = "results/trimmomatic/{sample}_R2_paired.fastq.gz",
        r2_unpaired = "results/trimmomatic/{sample}_R2_unpaired.fastq.gz"
    params:
        adapters = config["trimmomatic"]["adapters"],
        leading = config["trimmomatic"]["leading"],
        trailing = config["trimmomatic"]["trailing"],
        slidingwindow = config["trimmomatic"]["slidingwindow"],
        minlen = config["trimmomatic"]["minlen"]
    threads: 4
    log:
        "logs/trimmomatic/{sample}.log"
    shell:
        """
        trimmomatic PE -threads {threads} \
            {input.r1} {input.r2} \
            {output.r1_paired} {output.r1_unpaired} \
            {output.r2_paired} {output.r2_unpaired} \
            ILLUMINACLIP:{params.adapters}:2:30:10 \
            LEADING:{params.leading} \
            TRAILING:{params.trailing} \
            SLIDINGWINDOW:{params.slidingwindow} \
            MINLEN:{params.minlen} \
            2> {log}
        """

# Rule for quality assessment with FastQC
rule fastqc:
    input:
        r1 = "results/trimmomatic/{sample}_R1_paired.fastq.gz",
        r2 = "results/trimmomatic/{sample}_R2_paired.fastq.gz"
    output:
        html_r1 = "results/fastqc/{sample}_R1_paired_fastqc.html",
        html_r2 = "results/fastqc/{sample}_R2_paired_fastqc.html",
        zip_r1 = "results/fastqc/{sample}_R1_paired_fastqc.zip",
        zip_r2 = "results/fastqc/{sample}_R2_paired_fastqc.zip"
    threads: 2
    log:
        "logs/fastqc/{sample}.log"
    shell:
        """
        fastqc -t {threads} -o results/fastqc {input.r1} {input.r2} 2> {log}
        """

# Rule for filtering human reads with Kraken2
rule kraken2:
    input:
        r1 = "results/trimmomatic/{sample}_R1_paired.fastq.gz",
        r2 = "results/trimmomatic/{sample}_R2_paired.fastq.gz"
    output:
        r1_filtered = "results/kraken2/{sample}_R1_filtered.fastq",
        r2_filtered = "results/kraken2/{sample}_R2_filtered.fastq",
        report = "results/kraken2/{sample}_report.txt",
        classified = "results/kraken2/{sample}_classified.txt"
    params:
        db = config["kraken2"]["database"]
    threads: 8
    log:
        "logs/kraken2/{sample}.log"
    shell:
        """
        kraken2 --db {params.db} \
            --threads {threads} \
            --paired \
            --unclassified-out results/kraken2/{wildcards.sample}_R#_filtered.fastq \
            --classified-out results/kraken2/{wildcards.sample}_R#_classified.fastq \
            --report {output.report} \
            --output {output.classified} \
            {input.r1} {input.r2} \
            2> {log}
        """

# Rule for genome assembly with Unicycler
rule unicycler:
    input:
        r1 = "results/kraken2/{sample}_R1_filtered.fastq",
        r2 = "results/kraken2/{sample}_R2_filtered.fastq"
    output:
        assembly = "results/unicycler/{sample}/assembly.fasta",
        gfa = "results/unicycler/{sample}/assembly.gfa",
        log = "results/unicycler/{sample}/unicycler.log"
    threads: 8
    log:
        "logs/unicycler/{sample}.log"
    shell:
        """
        unicycler -1 {input.r1} -2 {input.r2} \
            -o results/unicycler/{wildcards.sample} \
            -t {threads} \
            2> {log}
        """

# Rule for assembly quality check with checkM
rule checkm:
    input:
        assembly = "results/unicycler/{sample}/assembly.fasta"
    output:
        results = "results/checkm/{sample}/checkm_results.txt"
    params:
        bin_dir = "results/unicycler/{sample}",
        output_dir = "results/checkm/{sample}"
    threads: 8
    log:
        "logs/checkm/{sample}.log"
    shell:
        """
        mkdir -p {params.output_dir}
        checkm lineage_wf \
            -t {threads} \
            -x fasta \
            --tab_table \
            -f {output.results} \
            {params.bin_dir} \
            {params.output_dir} \
            2> {log}
        """

# Rule for assembly quality check with Quast
rule quast:
    input:
        assembly = "results/unicycler/{sample}/assembly.fasta"
    output:
        report = "results/quast/{sample}/report.html",
        txt = "results/quast/{sample}/report.txt"
    threads: 4
    log:
        "logs/quast/{sample}.log"
    shell:
        """
        quast.py {input.assembly} \
            -o results/quast/{wildcards.sample} \
            -t {threads} \
            2> {log}
        """
