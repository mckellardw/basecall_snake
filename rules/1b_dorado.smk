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

# run basecallling on each run
rule basecall_DORADO:
    input:        
        POD5_DIRS = lambda wildcards: POD5_DIRS[f"{wildcards.EXPT}/{wildcards.SAMPLE}".replace(" ","")]
    output:
        BAM = "{OUTDIR}/{EXPT}/{SAMPLE}/dorado/{MODEL}/unaligned.bam"
    params:
        MIN_Q_SCORE=8,
        CUDA_DEVICE = "cuda:all",
        OUTDIR = "{OUTDIR}/{EXPT}/{SAMPLE}",
        MODCALL = config['MODS']
    wildcard_constraints:
        MODEL=MODEL_REGEX,
        IN_DIR=IN_DIR,
        OUTDIR=OUTDIR
    log:
        "{OUTDIR}/{EXPT}/{SAMPLE}/dorado/{MODEL}/basecaller.log"
    # benchmark:
    #     "{OUTDIR}/{EXPT}/{SAMPLE}/dorado/{MODEL}/basecaller_benchmark.txt"
    resources:
        partition="gpu",
        time="00-8:00:00",
        mem="8G",
        slurm_extra="--gres=gpu:1"
    run:
        tmpdir = f"{params.OUTDIR}/dorado/{wildcards.MODEL}/tmp".replace(" ", "")

        shell( # make tmp directory
            f"""
            mkdir -p {tmpdir}
            """
        )
        
        # If we're interested in m6a calling, add option to dorado
        if 'm6a' in {params.MODCALL}:
            mods='--modified-bases m6A_DRACH'
        else:
            mods=''

        # run basecalling on each individual run 
        for POD5_DIR in input.POD5_DIRS:
            current_run = POD5_DIR.rsplit("/")[-3]
            print(
                f"Basecalling on run {current_run}..."
            )
            shell(
                f"""
                {EXEC['DORADO']} basecaller \
                    --recursive \
                    --verbose \
                    --device {params.CUDA_DEVICE} \
                    {mods} \
                    --no-trim \
                    --emit-moves \
                    --min-qscore {params.MIN_Q_SCORE} \
                    {MODELS_DICT[wildcards.MODEL]} {POD5_DIR} \
                    > {tmpdir}/{current_run}.bam \
                    2> {log}
                """
            )
        
            # merge output files
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
                  mv {tmpdir}/{current_run}.bam {output.BAM}
                  """
                )

# merge unaligned bams across chunks
'''
rule merge_bams:
    input:
        DIR = "{OUTDIR}/{EXPT}/{SAMPLE}/dorado/{MODEL}/"
    output:
        BAM = "{OUTDIR}/{EXPT}/{SAMPLE}/dorado/{MODEL}/unaligned.bam"
    run:
        shell(
            f"""
            samtools merge -o {output.BAM} {input.DIR}/unaligned_*.bam
            """
        )
'''
