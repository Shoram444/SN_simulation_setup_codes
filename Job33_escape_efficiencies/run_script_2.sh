#!/bin/sh

# SLURM options:
#SBATCH --job-name=eff
#SBATCH --partition=htc
#SBATCH --mem=16G
#SBATCH --licenses=sps
#SBATCH --time=0-3
#SBATCH --cpus-per-task=1

echo "exported vairables:"
WORK_DIR=$E_DIR/${SLURM_ARRAY_TASK_ID}
pwd 

cd ${WORK_DIR}

echo "FAL: "${FAL}
echo "DATA_FOLDER: "${DATA_FOLDER}
echo "MAIN_FOLDER: "${MAIN_FOLDER}
echo "ROOT_FOLDER: "${ROOT_FOLDER}
echo "SLURM_ARRAY_TASK_ID: "${SLURM_ARRAY_TASK_ID}
echo "WORK_DIR: "${WORK_DIR}

${FAL}/flsimulate -c ${WORK_DIR}/simu.conf -o SD.brio
${FAL}/flreconstruct -i ${WORK_DIR}/SD.brio -p ${MAIN_FOLDER}/SNCuts_conf/Escaped1.conf -o SD_esc1.brio

rm SD.brio

WHEN USING TIT
${FAL}/flreconstruct -i SD_esc1.brio -p ${MAIN_FOLDER}/TIT_conf/MockCalibratePipeline.conf -o CD.brio
${FAL}/flreconstruct -i CD.brio -p ${MAIN_FOLDER}/TIT_conf/TKReconstructPipeline.conf -o CD.brio
${FAL}/flreconstruct -i CD.brio -p ${MAIN_FOLDER}/TIT_conf/PTD_tracking.conf -o CD.brio

rm SD_esc1.brio

cp ${MAIN_FOLDER}/Job33_eff.cpp .
cp ${MAIN_FOLDER}/Job33.cpp .

${FAL}/flreconstruct -p ${MAIN_FOLDER}/p_MiModule_v00.conf -i CD.brio 
${ROOT_FOLDER}/root -l -b Job33_eff.cpp

mv efficiency_count.root ${WORK_DIR}/efficiency_count.root
mv Default.root ${WORK_DIR}/Default_count.root

${FAL}/flreconstruct -i CD.brio -p ${MAIN_FOLDER}/SNCuts_conf/SNCutsPipeline.conf -o CD.brio

${FAL}/flreconstruct -p ${MAIN_FOLDER}/p_MiModule_v00.conf -i CD.brio
${ROOT_FOLDER}/root -l -b Job33.cpp

mv efficiency.root ${WORK_DIR}/efficiency.root
mv Default.root ${WORK_DIR}/Default_eff.root
rm ${WORK_DIR}/SD.brio ${WORK_DIR}/CD.brio ${WORK_DIR}/Default.root


