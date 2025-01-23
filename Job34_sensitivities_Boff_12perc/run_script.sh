#!/bin/sh

# SLURM options:
#SBATCH --job-name=eff
#SBATCH --partition=flash
#SBATCH --mem=16G
#SBATCH --licenses=sps
#SBATCH --time=0-1
#SBATCH --cpus-per-task=1

echo "exported vairables:"
WORK_DIR=$SIM_DIR/${SLURM_ARRAY_TASK_ID}
pwd 

cd ${WORK_DIR}

echo "FAL: "${FAL}
echo "DATA_FOLDER: "${DATA_FOLDER}
echo "MAIN_FOLDER: "${MAIN_FOLDER}
echo "ROOT_FOLDER: "${ROOT_FOLDER}
echo "SLURM_ARRAY_TASK_ID: "${SLURM_ARRAY_TASK_ID}
echo "WORK_DIR: "${WORK_DIR}

${FAL}/flsimulate -c ${WORK_DIR}/simu.conf -o SD.brio

# USING TKReconstruct
${FAL}/flreconstruct -i SD.brio -p ${MAIN_FOLDER}/TIT_conf/MockCalibratePipeline.conf -o CD.brio
${FAL}/flreconstruct -i CD.brio -p ${MAIN_FOLDER}/TIT_conf/TKReconstructPipeline.conf -o CD.brio
${FAL}/flreconstruct -i CD.brio -p ${MAIN_FOLDER}/TIT_conf/PTD_tracking.conf -o CD.brio

# MiModule
${FAL}/flreconstruct -i CD.brio -p ${MAIN_FOLDER}/SNCuts_conf/SNCutsPipeline.conf -o CD.brio

# Job23 root macro
${FAL}/flreconstruct -p ${MAIN_FOLDER}/p_MiModule_v00.conf -i CD.brio 
${ROOT_FOLDER}/root -l -b Job23.cpp

