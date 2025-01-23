#!/bin/sh

# SLURM options:
#SBATCH --job-name=eff
#SBATCH --partition=htc
#SBATCH --mem=8G
#SBATCH --licenses=sps
#SBATCH --time=0-1
#SBATCH --cpus-per-task=1

echo "exported vairables:"
WORK_DIR=$E_DIR/${SLURM_ARRAY_TASK_ID}
pwd 

cd ${WORK_DIR}

cp ${MAIN_FOLDER}/Job33_eff.cpp .
${ROOT_FOLDER}/root -l -b Job33_eff.cpp



