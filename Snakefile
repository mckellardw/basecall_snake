########################################################################################################
# basecall_snake
#   Snakemake workflow to run basecalling on fast5 files...
#   Written by David W. McKellar
########################################################################################################

########################################################################################################
# Config file
########################################################################################################
configfile:'config.yaml'

########################################################################################################
# Imports
########################################################################################################
import glob
import os
import re
import itertools

########################################################################################################
# Directories and run settings
########################################################################################################
# TMPDIR = config['TMPDIR']
IN_DIR = config['IN_DIR'].replace(" ","")
OUTDIR = config['OUTDIR'].replace(" ","")

########################################################################################################
# Variables and references
########################################################################################################
MODELS_DICT = config['MODELS']
EXPTS = config['EXPTS']

EXPT_SAMPLE_LIST=[f"{EXPT}/{SAMPLE}".replace(" ","") for EXPT, SAMPLES in EXPTS.items() for SAMPLE in SAMPLES]

POD5_DIRS = {}
POD5_FILES = {}
for ES in EXPT_SAMPLE_LIST:
    POD5_DIRS[ES]  = glob.glob(f"{IN_DIR}/{ES}/*/pod5_pass/".replace(" ",""))
    POD5_FILES[ES] = glob.glob(f"{IN_DIR}/{ES}/*/pod5_pass/*.pod5".replace(" ",""))

# EXPT_SAMPLE_REGEX=r"^E[\d]+\/[-\w]+$"
EXPT_SAMPLE_REGEX=r"[-\w]+"

# MODEL_REGEX=r"sup"
MODEL_REGEX=r"[-\w]+"

########################################################################################################
# Executables
########################################################################################################
EXEC = config['EXEC']

########################################################################################################
# Pipeline
########################################################################################################

localrules: all

rule all:
    input:
        expand( # Dorado unaligned .bam outputs
            "{OUTDIR}/{EXPT_SAMPLE}/dorado/{MODEL}/{FILE}",
            OUTDIR = config['OUTDIR'],
            EXPT_SAMPLE = EXPT_SAMPLE_LIST,
            # EXPT_SAMPLE = [f"{EXPT}/{SAMPLE}".replace(" ","") for EXPT, SAMPLES in EXPTS.items() for SAMPLE in SAMPLES],
            MODEL = MODELS_DICT.keys(),
            FILE = ['unaligned.bam']
        ), # ,'pod5_list.txt'
        # expand( # Guppy outputs [PLACEHOLDER]
        #     "{OUTDIR}/{EXPT_SAMPLE}/guppy/{MODEL}/{FILES}",
        #     OUTDIR = config['OUTDIR'],
        #     EXPT_SAMPLE = EXPT_SAMPLE_LIST,
        #     MODEL = MODELS_DICT.keys(),
        #     FILES = ['pod5_list.txt']
        # ), 
        [ # sample run info
            f"{OUTDIR}/{EXPT}/{SAMPLE}/pod5.txt".replace(" ","") for EXPT in EXPTS for SAMPLE in EXPTS[EXPT]
        ]
    wildcard_constraints:
        EXPT = EXPT_SAMPLE_REGEX,
        SAMPLE = EXPT_SAMPLE_REGEX,
        OUTDIR = OUTDIR

# Write .pod5 file list used for each sample
rule list_sample_runs:
    input:
        POD5_LIST = lambda wildcards: POD5_FILES[f"{wildcards.EXPT}/{wildcards.SAMPLE}".replace(" ","")]
    output:
        SAMPLE_RUNS = "{OUTDIR}/{EXPT}/{SAMPLE}/pod5.txt"
    resources:
        mem_mb=4000,
        mem_mib=4000,
        disk_mb=0, 
        disk_mib=0
    wildcard_constraints:
        EXPT = EXPT_SAMPLE_REGEX,
        SAMPLE = EXPT_SAMPLE_REGEX,
        OUTDIR = OUTDIR
    run:
        print(output.SAMPLE_RUNS[1])
        with open(output.SAMPLE_RUNS, 'w') as f:
            f.writelines(
                [s + '\n' for s in input.POD5_LIST]
            )

# split .pod5 files in each sample to chunks of fixed size
'''
rule split_pod5:
    input:
        POD5_DIRS = lambda wildcards: POD5_DIRS[f"{wildcards.EXPT}/{wildcards.SAMPLE}".replace(" ","")]
    output:
        temp("{OUTDIR}/{EXPT}/{SAMPLE}/.done")
    wildcard_constraints:
        EXPT = EXPT_SAMPLE_REGEX,
        SAMPLE = EXPT_SAMPLE_REGEX,
        MODEL = MODEL_REGEX,
        IN_DIR = IN_DIR,
        OUTDIR = OUTDIR
    params:
        SIZE = 10
    run:
        shell(f"""python -u scripts/py/split_pod5s.py {params.SIZE} {' '.join([d for d in POD5_DIRS])}""")
'''
include: "rules/1a_guppy.smk"
include: "rules/1b_dorado.smk"