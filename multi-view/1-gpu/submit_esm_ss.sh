#!/bin/bash
#Written by ULAB 02/24/2022
#SBATCH --partition=V4V32_CAS40M192_L			#Name of the partition
#SBATCH --job-name ss-1gpu			#Nameof the job
#SBATCH --output slurm-ss1g-%j.out                #Output file name
#SBATCH -e slurm-ss1g-%j.err                      #error file name
#SBATCH --account=gol_qsh226_uksr 			#SLurm Account
#SBATCH --ntasks=10					#Number of cores
#SBATCH --gres=gpu:1					#Number of GPU's needed
#SBATCH --mail-type ALL
#SBATCH --mail-user ulab222@uky.edu			#Email to forward
#SBATCH --time=66:00:00					#Time required for the Jupyter job

module load ccs/cuda/11.2.0_460.27.04
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/ohpc/pub/utils/ccs/cuda/10.1.115/toolkit/targets/x86_64-linux/lib/
module load ccs/Miniconda3
conda init
source ~/.bashrc
source activate protein
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

# This tests simCLR on PEER benchmark
#python3 script-peer/run_single_ESM_ss.py -c ./config/single_task/ESM/ss_ESM.yaml --seed 0
python3 -m torch.distributed.launch --nproc_per_node=1 script-peer/run_single_ESM_ss.py -c ./config/single_task/ESM/ss_ESM.yaml --seed 0

#load model
