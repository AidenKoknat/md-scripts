#!/bin/bash
#SBATCH --time=35:15:00             # Time limit for the job (REQUIRED).
#SBATCH --job-name=batch4-mv    # Job name
#SBATCH --nodes=1               # Number of nodes to allocate. Same as SBATCH -N (Don't use this option for mpi jobs)
#SBATCH --ntasks=1                  # Number of cores for the job. Same as SBATCH -n 1
#SBATCH -c 64
#SBATCH --mem=128g
#SBATCH --partition=normal          # Partition/queue to run the job in. (REQUIRED)
#SBATCH -e slurm-pdbmv4-%j.err             # Error file for this job.
#SBATCH -o slurm-pdbmv4-%j.out             # Output file for this job.
#SBATCH -A xxx       # Project allocation account name (REQUIRED)
#SBATCH --mail-type ALL         # Send email when job starts/ends
#SBATCH --mail-user xxx@xxx   # Where email is sent to (optional)

module load Miniconda3
#conda init
source ~/.bashrc
source activate py310

# This runs a script to sample batches 2-5 based on proteins not in batch 1.
./batch-mv.sh . "AF*.pdb" ./pdb-files
