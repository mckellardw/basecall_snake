#!/usr/bin/bash
#SBATCH --job-name=basecall_snake         # Job name
#SBATCH --mem=32G                            # Job memory request. Different units can be specified using the suffix [K|M|G|T]
#SBATCH --time=18:00:00                       # Time limit 12 hours
#SBATCH --output=./basecall_snake_%j.log               # Standard output and error log
#SBATCH --cpus-per-task=8 					# num cores

module load samtools
module load dorado
source activate basecalling

sbatch snakemake --cluster-config slurm_config.yml --cluster "sbatch --mail-type {cluster.mail-type} --mail-user {cluster.mail-user} -p {cluster.partition} -t {cluster.time} --mem {cluster.mem} -D {cluster.chdir} --output={cluster.output} --gres={cluster.gres}" -k --cluster-cancel scancel --local-cores 8 -j 4