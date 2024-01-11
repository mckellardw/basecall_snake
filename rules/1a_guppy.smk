# run basecallling
rule basecall_GUPPY:
    input:
        DIR = "{OUTDIR}/{EXPT}/{SAMPLE}",
        POD5_DIRS = glob.glob("{IN_DIR}/{EXPT}/{SAMPLE}/*/pod5_pass")
    output:
        # DIR = directory("{OUTDIR}/{EXPT_SAMPLE}/guppy"),
        POD5_LIST = "{OUTDIR}/{EXPT}/{SAMPLE}/guppy/{MODEL}/pod5_list.txt"
        # BAM = "{OUTDIR}/{EXPT_SAMPLE}/guppy/{MODEL}/unaligned.bam"
    wildcard_constraints:
        EXPT_SAMPLE=EXPT_SAMPLE_REGEX,
        MODEL=MODEL_REGEX,
        IN_DIR=IN_DIR,
        OUTDIR=OUTDIR
    params:
        MIN_Q_SCORE=8
    run:
        shell(
            f"""
            echo {input.POD5_DIRS} > {output.POD5_LIST}
            """
            # mkdir -p {output.DIR}
            # {EXEC['GUPPY']} -i {input.FAST5} -s {output.FASTQ} -c dna_r9.4.1_450bps_sup.cfg
            # "guppy_basecaller -i {input} -s {output} -c dna_r9.4.1_450bps_fast.cfg --recursive"
            # f"""
            # echo {input.FAST5}
            # """
        )

# gzip all of the basecalled fastqs
# rule compress_fastqs:
#     input:
#         FASTQ = [f"{OUTDIR}/{os.path.basename(F5)}".replace('.fast5', '.fastq') for F5 in glob.glob(f"{FAST5_DIR}/*.fast5")]
#     output:
#         FASTQGZ = [f"{OUTDIR}/{os.path.basename(F5)}".replace('.fast5', '.fastq.gz') for F5 in glob.glob(f"{FAST5_DIR}/*.fast5")]
#     threads:
#         config['nTHREADS']
#     run:
#         shell(
#             f"""
#             pigz -p{threads} {input.FASTQ}
#             """
#         )