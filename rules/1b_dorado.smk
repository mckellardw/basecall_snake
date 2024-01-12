# download dorado models
# rule download_models:
#     output:
#        MODELS = expand("{MODEL}", MODEL=MODELS_DICT.values()
#     run:
#        
#         shell(
#             f"""
#             {EXEC["DORADO"]} download \
#             --directory resources/dorado_models
#             """
#         )


# Write a list of runs used in basecalling
rule list_input_runs_DORADO:
    input:        
        DIR = "{OUTDIR}/{EXPT}/{SAMPLE}",
        POD5_DIRS = lambda wildcards: POD5_DIRS[f"{wildcards.EXPT}/{wildcards.SAMPLE}".replace(" ","")]
    output:
        POD5_LIST = "{OUTDIR}/{EXPT}/{SAMPLE}/dorado/{MODEL}/pod5_list.txt"
    params:
    resources:

    wildcard_constraints:
        EXPT = EXPT_SAMPLE_REGEX,
        SAMPLE = EXPT_SAMPLE_REGEX,
        MODEL = MODEL_REGEX,
        IN_DIR = IN_DIR,
        OUTDIR = OUTDIR
    run:
        with open(output.POD5_LIST, 'w') as f:
            f.writelines(
                [f"{s}\n" for s in input.POD5_DIRS]
            )

# run basecallling on each run
#TODO- optionally, modify to run on individual pod5 files?
#TODO- split into multiple rules to shorten per-rule runtime (slurm!)
rule basecall_DORADO:
    input:        
        DIR = "{OUTDIR}/{EXPT}/{SAMPLE}",
        POD5_DIRS = lambda wildcards: POD5_DIRS[f"{wildcards.EXPT}/{wildcards.SAMPLE}".replace(" ","")]
    output:
        BAM = "{OUTDIR}/{EXPT}/{SAMPLE}/dorado/{MODEL}/unaligned.bam"
    params:
        MIN_Q_SCORE=8,
        CUDA_DEVICE = "cuda:all"
        # CUDA_DEVICE = "cpu"
    wildcard_constraints:
        # EXPT = EXPT_SAMPLE_REGEX,
        # SAMPLE = EXPT_SAMPLE_REGEX,
        MODEL=MODEL_REGEX,
        IN_DIR=IN_DIR,
        OUTDIR=OUTDIR
    log:
        "{OUTDIR}/{EXPT}/{SAMPLE}/dorado/{MODEL}/basecaller.log"
    # benchmark:
    #     "{OUTDIR}/{EXPT}/{SAMPLE}/dorado/{MODEL}/basecaller_benchmark.txt"
    run:
        tmpdir = f"{input.DIR}/dorado/{wildcards.MODEL}/tmp".replace(" ", "")

        shell( # make tmp directory
            f"""
            mkdir -p {tmpdir}
            """
        )
        
        # run basecalling on each individual run - just on 
        for POD5_DIR in input.POD5_DIRS:
            current_run = POD5_DIR.rsplit("/")[-2]
            print(
                f"Basecalling on run {current_run}..."
            )
            shell(
                f"""
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

        # merge output .bams
        if len(input.POD5_DIRS) > 1:
            shell(
                f"""
                {EXEC["SAMTOOLS"]} cat \
                    -o {output.BAM} \
                    {tmpdir}/*.bam
                """
            )
        else:
            shell(
                f"""
                mv {tmpdir}/{input.POD5_DIRS[0]}.bam {output.BAM}                    
                """
            )