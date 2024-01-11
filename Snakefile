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

THREADS = config['THREADS']

########################################################################################################
# Variables and references
########################################################################################################
MODELS_DICT = config['MODELS']
EXPTS = config['EXPTS']

EXPT_SAMPLE_LIST=[f"{EXPT}/{SAMPLE}".replace(" ","") for EXPT, SAMPLES in EXPTS.items() for SAMPLE in SAMPLES]

POD5_DIRS = {}
POD5_FILES = {}
for ES in EXPT_SAMPLE_LIST:
    POD5_DIRS[ES]  = glob.glob(f"{IN_DIR}/{ES}/*/pod5_pass".replace(" ",""))
    POD5_FILES[ES] = glob.glob(f"{IN_DIR}/{ES}/*/pod5_pass/*.pod5".replace(" ",""))

EXPT_SAMPLE_REGEX=r"^E[\d]+\/[-\w]+$"
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

# for ES in EXPT_SAMPLE_LIST:
#     print(ES)
#     print(
#         re.search(EXPT_SAMPLE_REGEX, ES)
#     )

# print([f"{OUTDIR}/{e}/{s}".replace(" ","") for e in EXPTS for s in EXPTS[e]])

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
        # expand( # Guppy outputs [PLACEHOLDER]
        #     "{OUTDIR}/{EXPT_SAMPLE}/guppy/{MODEL}/{FILES}",
        #     OUTDIR = config['OUTDIR'],
        #     EXPT_SAMPLE = EXPT_SAMPLE_LIST,
        #     MODEL = MODELS_DICT.keys(),
        #     FILES = ['pod5_list.txt']
        # ), 
        [ # sample run info
            f"{OUTDIR}/{e}/{s}/pod5.txt".replace(" ","") for e in EXPTS for s in EXPTS[e]
        ]
    # wildcard_constraints:
    #     EXPT_SAMPLE = EXPT_SAMPLE_REGEX,
    #     OUTDIR=OUTDIR

# Initialize sample output directories
# rule build_sample_dirs:
#     output:
#         DIR = directory("{OUTDIR}/{EXPT}/{SAMPLE}")
#     # wildcard_constraints:
#     #     EXPT_SAMPLE = EXPT_SAMPLE_REGEX,
#     #     OUTDIR=OUTDIR
#     run:
#         #Build outdirs for each sample, based on ONT input file structure (`.../EXPT/SAMPLE`)
#         shell(
#             f"""
#             mkdir -p {output.DIR}
#             """
#         )

# Write .pod5 file list used for each sample
rule list_sample_runs:
    input:
        # DIR = "{OUTDIR}/{EXPT}/{SAMPLE}",
        POD5_LIST = lambda wildcards: POD5_FILES[f"{wildcards.EXPT}/{wildcards.SAMPLE}".replace(" ","")]
    output:
        SAMPLE_RUNS = "{OUTDIR}/{EXPT}/{SAMPLE}/pod5.txt"
    resources:
        mem_mb=4000, 
        mem_mib=4000,
        disk_mb=0, 
        disk_mib=0
    run:
        #Build outdirs for each sample, based on ONT input file structure (`.../EXPT/SAMPLE`)
        # POD5_FILES = glob.glob(f"{IN_DIR}/{wildcards.EXPT_SAMPLE}/*/pod5_pass/*.pod5".replace(" ",""))
        print(output.SAMPLE_RUNS[1])
        with open(output.SAMPLE_RUNS, 'w') as f:
            f.writelines(
                [s + '\n' for s in input.POD5_LIST]
            )

include: "rules/1a_guppy.smk"
include: "rules/1b_dorado.smk"