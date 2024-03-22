rule nanospa_align:
    input:
        FASTQ_DIR="{OUTDIR}/{EXPT}/{SAMPLE}/dorado/{MODEL}/"
    output:
        BASE_DIR="{OUTDIR}/{EXPT}/{SAMPLE}/nanospa/",
        ALIGN_DIR="{OUTDIR}/{EXPT}/{SAMPLE}/nanospa/align/"
    params:
        REF=config['REF_TR']
    conda: nanospa
    run:
        shell(
          f"""
            mkdir {output.BASE_DIR}
          """
        )
        shell(
          f"""
            nanospa alignment -i {input.FASTQ_DIR} -r {params.REF} -o {output.ALIGN_DIR}
          """
        )

rule nanospa_remove_intron:
    input:
        ALIGN_DIR="{OUTDIR}/{EXPT}/{SAMPLE}/nanospa/align/"
    output:
        PLUS_STRAND="{OUTDIR}/{EXPT}/{SAMPLE}/nanospa/align/plus_strand/collect_pile_no_intron.txt",
        MINUS_STRAND="{OUTDIR}/{EXPT}/{SAMPLE}/nanospa/align/minus_strand/collect_pile_no_intron.txt"
    conda: nanospa
    run:
        shell(
          f"""
              nanospa remove_intron -i {input.ALIGN_DIR}
          """)

rule nanospa_extract:
    input:
        ALIGN_DIR="{OUTDIR}/{EXPT}/{SAMPLE}/nanospa/align/",
        # Not technically needed as a parameter, we just add to input to ensure that it's generated
        PLUS_STRAND="{OUTDIR}/{EXPT}/{SAMPLE}/nanospa/align/plus_strand/collect_pile_no_intron.txt",
        MINUS_STRAND="{OUTDIR}/{EXPT}/{SAMPLE}/nanospa/align/minus_strand/collect_pile_no_intron.txt"
    output:
        FEATURES="{OUTDIR}/{EXPT}/{SAMPLE}/nanospa/features.csv"
    conda: nanospa
    run:
        shell(
          f"""
              nanospa extract_features -i {input.align_DIR} -o {output.FEATURES}
          """
        )

'''
rule nanospa_psu_predict:
    input:
    output:
    config:
    run:
'''

rule nanospa_preprocess_m6a:
    input:
        FEATURES="{OUTDIR}/{EXPT}/{SAMPLE}/nanospa/features.csv"
    output:
        DIR="{OUTDIR}/{EXPT}/{SAMPLE}/nanospa/m6a"
    conda: nanospa
    run:
        shell(
          f"""
              mkdir {output.DIR}
              nanospa preprocess_m6A -i {input.FEATURES} -o {output.DIR}
          """
        )

rule nanospa_m6a_predict:
    input:
        DIR="{OUTDIR}/{EXPT}/{SAMPLE}/nanospa/m6a"
    output:
        PREDICT_CSV="{OUTDIR}/{EXPT}/{SAMPLE}/nanospa/m6a/prediction.csv"
    conda: nanospa
    run:
        shell(
          f"""
              nanospa prediction_m6A -i {input.DIR} -o {output.PREDICT_CSV}
          """
        )
