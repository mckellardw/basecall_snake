rule m6anet_align:
    input:
        FASTQ="{OUTDIR}/{EXPT}/{SAMPLE}/dorado/{MODEL}/unaligned.fastq"
    output:
        BASE_DIR="{OUTDIR}/{EXPT}/{SAMPLE}/m6anet/dataprep/",
        SAM=temp("{OUTDIR}/{EXPT}/{SAMPLE}/m6anet/transcriptome_aligned.sam"),
        BAM="{OUTDIR}/{EXPT}/{SAMPLE}/m6anet/dataprep/transcriptome_aligned.sorted.bam",
        BAI="{OUTDIR}/{EXPT}/{SAMPLE}/m6anet/dataprep/transcriptome_aligned.sorted.bam.bai"
    params:
        REF=config['REF_TR']
    conda: m6anet
    run:
        shell(f"""
            mkdir {output.BASE_DIR}
            minimap2 -ax map-ont -uf --secondary=no -t 4 {input.FASTQ} {params.REF} > {output.SAM}
            samtools sort -@ 4 {output.SAM} -o {output.BAM}
            samtools index -@ 4 {output.BAM}
        """)

rule convert_to_fast5:
    input:
        POD5_DIRS = lambda wildcards: POD5_DIRS[f"{wildcards.EXPT}/{wildcards.SAMPLE}".replace(" ","")]
    output:
        FAST5_DIR="{OUTDIR}/{EXPT}/{SAMPLE}/m6anet/fast5s"
    conda: m6anet
    run:
        for DIR in input.POD5_DIRS:
            shell(f"""
                pod5 convert to_fast5 {DIR} --output {output.FAST5_DIR}
            """)

rule m6anet_eventalign:
    input:
        FASTQ="{OUTDIR}/{EXPT}/{SAMPLE}/dorado/{MODEL}/unaligned.fastq",
        BAM="{OUTDIR}/{EXPT}/{SAMPLE}/m6anet/dataprep/transcriptome_aligned.sorted.bam",
        FAST5_DIR="{OUTDIR}/{EXPT}/{SAMPLE}/m6anet/fast5s"
    output:
        FASTQ="{OUTDIR}/{EXPT}/{SAMPLE}/m6anet/dataprep/unaligned.fastq",
        SUMMARY="{OUTDIR}/{EXPT}/{SAMPLE}/m6anet/dataprep/summary.txt",
        EVENTALIGN="{OUTDIR}/{EXPT}/{SAMPLE}/m6anet/dataprep/eventalign.txt"
    params:
        REF=config['REF_TR']
    conda: m6anet
    run:
        shell("""
            export HDF5_PLUGIN_PATH=${HOME}/.conda/envs/m6anet/hdf5/lib/plugin
        """)
        shell(f"""
            cp {input.FASTQ} {output.FASTQ} 
            nanopolish index -d {input.FAST5_DIR} {output.FASTQ}
            nanopolish eventalign --reads {output.FASTQ} --bam {input.BAM} --genome {params.REF} --scale-events --signal-index --summary {output.SUMMARY} --threads 4 > {output.EVENTALIGN}
        """)

rule m6anet_dataprep:
    input:
        EVENTALIGN="{OUTDIR}/{EXPT}/{SAMPLE}/m6anet/dataprep/eventalign.txt"
    output:
        DATAPREP_OUTDIR="{OUTDIR}/{EXPT}/{SAMPLE}/m6anet/dataprep/out/",
        DATAPREP_JSON="{OUTDIR}/{EXPT}/{SAMPLE}/m6anet/dataprep/out/data.json"
    conda: m6anet
    run:
        shell(
          f"""
            mkdir {input.DATAPREP_OUTDIR}
            m6anet dataprep --eventalign {input.EVENTALIGN} --out_dir {output.DATAPREP_OUTDIR} --n_processes 4
          """
        )

rule m6anet_inference:
    input:
        DIR="{OUTDIR}/{EXPT}/{SAMPLE}/m6anet/dataprep/out/"
    output:
        DIR="{OUTDIR}/{EXPT}/{SAMPLE}/m6anet/results/"
    conda: m6anet
    run:
        shell(
          f"""
          mkdir {output.DIR}
          m6anet inference --input_dir {input.DIR} --out_dir {output.DIR} --pretrained_model HEK293T_RNA004 --n_processes 4 --num_iterations 1000
          """
        )

'''
rule add_to_bam:
'''
