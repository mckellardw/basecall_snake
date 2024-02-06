
# Install/dependencies:
```
dorado==0.5.1
snakemake==7.X.X
samtools
```

# Runtime:
Pre-run:
```
cd /gpfs/commons/groups/innovation/dwm/basecall_snake
module load samtools
module load dorado
```
<!-- module load guppy/6.1.2-gpu
module load cuda/11.3.1 -->

## Run w/ slurm:
```
snakemake --cluster-config slurm_config.yml \
--cluster "sbatch --mail-type {cluster.mail-type} -p {cluster.partition} -t {cluster.time} --mem {cluster.mem} -D {cluster.chdir} --output={cluster.output} --gres={cluster.gres}" --cluster-cancel \
-j 4 -k --local-cores 8
```

Note: in cluster execution `-j` controls the number of parallel gpu jobs that will be used to run basecalling, while `--local-cores` controls the number of local cpu threads that will be used for other tasks

## Run w/out slurm:
```
snakemake --nt -k -j 2
```

# Additional detiails:
## Dorado models:
[link to info from ONT](TODO)
How to download:
```
cd basecall_snake/
dorado download --directory resources/dorado models
```

## Guppy models:
- Location of all models on cluster:  
    `/nfs/sw/guppy/guppy-6.1.2-gpu/data/`

## Output tree (#TODO):
```
{OUTDIR}
    {sample}
        guppy
        dorado
            sup
                unaligned.bam
            hac
                unaligned.bam
```

# TODO:
- add snakemake v8 compatibility
- Fix slurm resource settings for `list_sample_runs`
- snakemake --lint
- Autodetect chemistry?
- Add other basecallers
- README
  - output tree
  - model info