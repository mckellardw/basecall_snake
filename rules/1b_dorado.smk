#TODO? download dorado models
# rule download_models:
#     output:
#         MODELS = "resources/dorado_models/{MODEL}"
#     run:
        
#         shell(
#             f"""
#             {EXEC["DORADO"]} download \
#             --directory resources/dorado_models
#             """
#         )

# run basecallling on each run
#TODO- optionally, modify to run on individual pod5 files?
#TODO- split into multiple rules to shorten per-rule runtime (slurm!)
#TODO- make {MODEL} a wildcard somehow...
#TODO- add a check for input pod5 files/dirs
rule basecall_DORADO:
    input:        
        DIR = "{OUTDIR}/{EXPT_SAMPLE}",
        POD5_DIRS = glob.glob("{IN_DIR}/{EXPT_SAMPLE}/*/pod5_pass".replace(" ",""))
    output:
        BAM = "{OUTDIR}/{EXPT_SAMPLE}/dorado/{MODEL}/unaligned.bam",
        POD5_LIST = "{OUTDIR}/{EXPT_SAMPLE}/dorado/{MODEL}/pod5_list.txt"
    params:
        MIN_Q_SCORE=8,
        # MODELS = MODELS_DICT.keys(),
        CUDA_DEVICE = "cuda:all"
        # CUDA_DEVICE = "cpu"
    wildcard_constraints:
        EXPT_SAMPLE = EXPT_SAMPLE_REGEX,
        MODEL=MODEL_REGEX
    log:
        "{OUTDIR}/{EXPT_SAMPLE}/dorado/{MODEL}/basecaller.log"
    benchmark:
        "{OUTDIR}/{EXPT_SAMPLE}/dorado/{MODEL}/basecaller_benchmark.txt"
    run:
        tmpdir = f"{input.DIR}/dorado/{wildcards.MODEL}/tmp".replace(" ", "")

        shell( # make tmp directory
            f"""
            mkdir -p {tmpdir}
            """
        )
        
        # run basecalling on each individual run - just on 
        for POD5_DIR in input.POD5_DIRS:
            current_run = POD5_DIR.rsplit("/")[-1]
            print(
                f"Basecalling on run {current_run}..."
            )
            shell(
                f"""
                touch {output.POD5_LIST}
                echo {glob.glob(f"{IN_DIR}/{wildcards.EXPT_SAMPLE}/*/pod5_pass/*.pod5")} >> {output.POD5_LIST}

                {EXEC['DORADO']} basecaller \
                    --recursive \
                    --verbose \
                    --device {params.CUDA_DEVICE} \
                    --no-trim \
                    --min-qscore {params.MIN_Q_SCORE} \
                    {MODELS_DICT[wildcards.MODEL]} {POD5_DIR} \
                    > {tmpdir}/{current_run}.bam \
                    2> {log}
                """
            )

        shell(
            f"""
            {EXEC["SAMTOOLS"]} cat \
                -o {output.BAM} \
                {tmpdir}/*.bam
            """
        )
        


# gzip all of the basecalled fastqs
# rule merge_runs:
#     input:
#         BAMS = []
#     output:
#         BAM = f"{OUTDIR}/{EXPT_SAMPLE}/dorado/{MODEL}/unaligned.bam"
#     threads:
#         config['nTHREADS']
#     run:
#         shell(
#             f"""
#             {EXEC["SAMTOOLS"]} merge
#             """
#         )