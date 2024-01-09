
# Install/dependencies:
#TODO- add snakemake v8 compatibility
```
dorado==0.5.1
snakemake==7.X.X
samtools
```

# Runtime:
```
cd /gpfs/commons/groups/innovation/dwm/basecall_snake
module load dorado
module load guppy/6.1.2-gpu
module load cuda/11.3.1
```

## Run w/ slurm:
```
snakemake --cluster-config slurm_config.yml \
--cluster "sbatch --mail-type {cluster.mail-type} --mail-user {cluster.mail-user} -p {cluster.partition} -t {cluster.time} -N {cluster.nodes} --mem {cluster.mem} -D {cluster.chdir} --gres=gpu:1" \
-j 8
```

## Run w/out slurm:
```
snakemake --nt -k -j 2
```

# Additional detiails:
## Dorado models
List of all models on cluster:
```
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.3_450bps_fast.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_modbases_5hmc_5mc_cg_hac.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.3_450bps_fast_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_modbases_5hmc_5mc_cg_hac_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.3_450bps_hac.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_modbases_5hmc_5mc_cg_sup.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.3_450bps_hac_prom.cfg
 /nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_modbases_5hmc_5mc_cg_sup_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.3_450bps_sup.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_modbases_5mc_cg_fast.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.4_e8.1_fast.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_modbases_5mc_cg_fast_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.4_e8.1_fast_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_modbases_5mc_cg_hac.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.4_e8.1_hac.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_modbases_5mc_cg_hac_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.4_e8.1_hac_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_modbases_5mc_cg_sup.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.4_e8.1_modbases_5hmc_5mc_cg_fast.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_modbases_5mc_cg_sup_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.4_e8.1_modbases_5hmc_5mc_cg_fast_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_sketch.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.4_e8.1_modbases_5hmc_5mc_cg_hac.cfg

/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_sup.cfg

/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.4_e8.1_modbases_5hmc_5mc_cg_hac_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_sup_plant.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.4_e8.1_modbases_5hmc_5mc_cg_sup.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_sup_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.4_e8.1_modbases_5mc_cg_fast.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_e8.1_fast.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.4_e8.1_modbases_5mc_cg_fast_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_e8.1_fast_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.4_e8.1_modbases_5mc_cg_hac.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_e8.1_hac.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.4_e8.1_modbases_5mc_cg_hac_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_e8.1_hac_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.4_e8.1_modbases_5mc_cg_sup.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_e8.1_modbases_5mc_cg_fast.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.4_e8.1_sketch.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_e8.1_modbases_5mc_cg_fast_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10.4_e8.1_sup.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_e8.1_modbases_5mc_cg_hac.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10_450bps_fast.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_e8.1_modbases_5mc_cg_hac_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r10_450bps_hac.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_e8.1_modbases_5mc_cg_sup.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_fast.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_e8.1_sketch.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_fast_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_e8.1_sup.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_hac.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.5_450bps.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_hac_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/rna_r9.4.1_70bps_fast.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_hac_prom_fw205.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/rna_r9.4.1_70bps_fast_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_modbases_5hmc_5mc_cg_fast.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/rna_r9.4.1_70bps_hac.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/dna_r9.4.1_450bps_modbases_5hmc_5mc_cg_fast_prom.cfg
/nfs/sw/guppy/guppy-6.1.2-gpu/data/rna_r9.4.1_70bps_hac_prom.cfg
```

## Output tree:
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