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

########################################################################################################
# Directories and run settings
########################################################################################################
# TMPDIR = config['TMPDIR']
IN_DIR = config['IN_DIR'].replace(" ","")
OUTDIR = config['OUTDIR'].replace(" ","")

THREADS = config['THREADS']

########################################################################################################
# Variables and references
########################################################################################################
MODELS_DICT = config['MODELS']
EXPTS = config['EXPTS']

EXPT_SAMPLE_LIST=[f"{EXPT}/{SAMPLE}".replace(" ","") for EXPT, SAMPLES in EXPTS.items() for SAMPLE in SAMPLES]

EXPT_SAMPLE_REGEX=r'^[-\w]+\/[-\w]+$'
MODEL_REGEX=r"sup"

########################################################################################################
# Executables
########################################################################################################
EXEC = config['EXEC']

########################################################################################################
# Troubleshooting
########################################################################################################

#Pre-flight check for pod5 directories:
# for ES in EXPT_SAMPLE_LIST:
#     print(f">>>> {ES}")
#     print(glob.glob(f"{IN_DIR}/{ES}/*/pod5_pass/".replace(" ","")))

# print(
#     expand( # Dorado unaligned .bam outputs
#             "{OUTDIR}/{EXPT_SAMPLE}/dorado/{MODEL}/{FILES}",
#             OUTDIR = config['OUTDIR'],
#             EXPT_SAMPLE = EXPT_SAMPLE_LIST,
#             MODEL = MODELS_DICT.keys(),
#             FILES = ['unaligned.bam','pod5_list.txt']
#         )
# )
# print(
#     expand( # Guppy outputs [PLACEHOLDER]
#             "{OUTDIR}/{EXPT_SAMPLE}/guppy/{MODEL}/{FILES}",
#             OUTDIR = config['OUTDIR'],
#             EXPT_SAMPLE = EXPT_SAMPLE_LIST,
#             MODEL = MODELS_DICT.keys(),
#             FILES = ['pod5_list.txt']
#         )
# )
# print(
#     expand( # sample run info
#             "{OUTDIR}/{EXPT_SAMPLE}/runs.txt",
#             OUTDIR = config['OUTDIR'],
#             EXPT_SAMPLE = EXPT_SAMPLE_LIST
#         )
# )

########################################################################################################
# Pipeline
########################################################################################################

rule all:
    input:
        expand( # Dorado unaligned .bam outputs
            "{OUTDIR}/{EXPT_SAMPLE}/dorado/{MODEL}/{FILES}",
            OUTDIR = config['OUTDIR'],
            EXPT_SAMPLE = EXPT_SAMPLE_LIST,
            MODEL = MODELS_DICT.keys(),
            FILES = ['unaligned.bam','pod5_list.txt']
        ),        
        expand( # Guppy outputs [PLACEHOLDER]
            "{OUTDIR}/{EXPT_SAMPLE}/guppy/{MODEL}/{FILES}",
            OUTDIR = config['OUTDIR'],
            EXPT_SAMPLE = EXPT_SAMPLE_LIST,
            MODEL = MODELS_DICT.keys(),
            FILES = ['pod5_list.txt']
        ), 
        expand( # sample run info
            "{OUTDIR}/{EXPT_SAMPLE}/runs.txt",
            OUTDIR = config['OUTDIR'],
            EXPT_SAMPLE = EXPT_SAMPLE_LIST
        )

# Initialize sample output directories
rule build_sample_dirs:
    output:
        DIR = directory("{OUTDIR}/{EXPT_SAMPLE}")
    wildcard_constraints:
        EXPT_SAMPLE = EXPT_SAMPLE_REGEX
    run:
        #Build outdirs for each sample, based on ONT input file structure (`.../EXPT/SAMPLE`)
        shell(
            f"""
            mkdir -p {output.DIR}
            """
        )
# Write .pod5 file list used for each sample
rule list_sample_runs:
    input:
        POD5_FILES = glob.glob("{IN_DIR}/{EXPT_SAMPLE}/*/pod5_pass/*.pod5".replace(" ",""))
    output:
        SAMPLE_RUNS = "{OUTDIR}/{EXPT_SAMPLE}/runs.txt"
    wildcard_constraints:
        EXPT_SAMPLE = EXPT_SAMPLE_REGEX
    run:
        #Build outdirs for each sample, based on ONT input file structure (`.../EXPT/SAMPLE`)
        shell(
            f"""
            echo {input.POD5_FILES} > {output.SAMPLE_RUNS}
            """
        )

include: "rules/1a_guppy.smk"
include: "rules/1b_dorado.smk"