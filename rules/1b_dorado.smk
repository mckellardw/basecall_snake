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

localrules: list_input_runs_DORADO

# Write a list of runs used in basecalling
rule list_input_runs_DORADO:
    input:        
#        DIR = "{OUTDIR}/{EXPT}/{SAMPLE}",
        POD5_DIRS = lambda wildcards: POD5_DIRS[f"{wildcards.EXPT}/{wildcards.SAMPLE}".replace(" ","")]
    output:
        POD5_LIST = "{OUTDIR}/{EXPT}/{SAMPLE}/dorado/{MODEL}/pod5_list.txt"
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

rule chunk_pod5:
    input:
        POD5_DIRS = lambda wildcards: POD5_DIRS[f"{wildcards.EXPT}/{wildcards.SAMPLE}".replace(" ","")]
    output:
        temp("{OUTDIR}/{EXPT}/{SAMPLE}/dorado/{MODEL}/.done")
    wildcard_constraints:
        EXPT = EXPT_SAMPLE_REGEX,
        SAMPLE = EXPT_SAMPLE_REGEX,
        MODEL = MODEL_REGEX,
        IN_DIR = IN_DIR,
        OUTDIR = OUTDIR
    run:
        tmpdir = f"{params.OUTDIR}/dorado/{wildcards.MODEL}/tmp".replace(" ", "")
        shell(f"python -u scripts/py/split_pod5.py {tmpdir} {' '.join([str(d) for d in POD5_DIRS])}")


# run basecallling on each run
'''
rule basecall_DORADO:
    input:        
        POD5_DIRS = lambda wildcards: POD5_DIRS[f"{wildcards.EXPT}/{wildcards.SAMPLE}".replace(" ","")]
    output:
        BAM = "{OUTDIR}/{EXPT}/{SAMPLE}/dorado/{MODEL}/unaligned.bam"
    params:
        MIN_Q_SCORE=8,
        CUDA_DEVICE = "cuda:all",
        # CUDA_DEVICE = "cpu"
        OUTDIR = "{OUTDIR}/{EXPT}/{SAMPLE}"
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
        tmpdir = f"{params.OUTDIR}/dorado/{wildcards.MODEL}/tmp".replace(" ", "")

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
'''

rule basecall_DORADO:
    input:        
        POD5_FILES = lambda wildcards: POD5_FILES[f"{wildcards.EXPT}/{wildcards.SAMPLE}".replace(" ","")]
    output:
        BAM = "{OUTDIR}/{EXPT}/{SAMPLE}/dorado/{MODEL}/unaligned.bam"
    params:
        MIN_Q_SCORE=8,
        CUDA_DEVICE = "cuda:all",
        # CUDA_DEVICE = "cpu"
        OUTDIR = "{OUTDIR}/{EXPT}/{SAMPLE}"
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
        tmpdir = f"{params.OUTDIR}/dorado/{wildcards.MODEL}/tmp".replace(" ", "")

        shell( # make tmp directory
            f"""
            mkdir -p {tmpdir}
            """
        )
        
        # split into chunks of N pod5s and run basecalling on each individually

        for i, POD5_FILE in enumerate(input.POD5_FILES):
            current_run = POD5_FILE.rsplit('/')[-4]
            current_chunk = f"{current_run}_chunk_{i+1}"
            if (i+1)%100 == 0:
              print(
                  f"Basecalling on run {current_run} chunk {i+1} of {len(input.POD5_FILES)}..."
              )
            shell(
                f"""
                {EXEC['DORADO']} basecaller \
                    --recursive \
                    --verbose \
                    --device {params.CUDA_DEVICE} \
                    --no-trim \
                    --min-qscore {params.MIN_Q_SCORE} \
                    {MODELS_DICT[wildcards.MODEL]} {POD5_FILE} \
                    > {tmpdir}/{current_chunk}.bam \
                    2> {log}
                """
            )

        # merge output files
        shell(
            f"""
            {EXEC["SAMTOOLS"]} cat \
                -o {output.BAM} \
                {tmpdir}/*.bam
            """
        )
