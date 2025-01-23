#!/bin/sh

# SLURM options:
#SBATCH --job-name=eff
#SBATCH --partition=htc
#SBATCH --mem=16G
#SBATCH --licenses=sps
#SBATCH --chdir=/tmp
#SBATCH --time=3-0
#SBATCH --cpus-per-task=1

# Calculate indices
ENERGY_INDEX=$((SLURM_ARRAY_TASK_ID / FILES_PER_COMB))
FILE_INDEX=$((SLURM_ARRAY_TASK_ID % FILES_PER_COMB))

# Map to energy and thickness
ENERGIES=(500 1500 2500 3000)
THICKNESSES=(100 150 200 250 300 400 500)

ENERGY=${ENERGIES[$((ENERGY_INDEX / ${#THICKNESSES[@]}))]}
THICKNESS=${THICKNESSES[$((ENERGY_INDEX % ${#THICKNESSES[@]}))]}

# Define folder paths dynamically
SIM_FOLDER=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster_sim_data/$USER_FOLDNAME
WORK_FOLDER=$SIM_FOLDER/${ENERGY}keV_${THICKNESS}um/$FILE_INDEX

# Ensure the working directory exists
mkdir -p $WORK_FOLDER
cd $WORK_FOLDER
exec > ${WORK_FOLDER}/OUT.log 2> ${WORK_FOLDER}/ERR.log

cp ${MAIN_FOLDER}/run_script_1.sh ${WORK_FOLDER}/run_script_1.sh

# Run simulation as before
echo "Running simulation for $ENERGY keV + $THICKNESS um, file $FILE_INDEX"

${FAL}/flsimulate -c ${WORK_FOLDER}/simu.conf -o SD.brio
${FAL}/flreconstruct -i SD.brio -p ${MAIN_FOLDER}/SNCuts_conf/Escaped1.conf -o SD.brio

echo " ls after flsimulate + esacped" 
ls -lh

# WHEN USING TIT
${FAL}/flreconstruct -i SD.brio -p ${MAIN_FOLDER}/TIT_conf/MockCalibratePipeline.conf -o CD.brio
${FAL}/flreconstruct -i CD.brio -p ${MAIN_FOLDER}/TIT_conf/TKReconstructPipeline.conf -o CD.brio
${FAL}/flreconstruct -i CD.brio -p ${MAIN_FOLDER}/TIT_conf/PTD_tracking.conf -o CD.brio

echo " ls after flreco1" 
ls -lh

# cp SD.brio ${WORK_FOLDER}/SD.brio              # if you want to keep CD.brio
# cp CD.brio ${WORK_FOLDER}/CD.brio              # if you want to keep CD.brio

echo "================================="
echo "FINISHED simulation, STARTING analysis!"
ls -l

cp ${MAIN_FOLDER}/Job33_eff.cpp .
cp Job33_eff.cpp $WORK_FOLDER/Job33_eff.cpp

${FAL}/flreconstruct -p ${MAIN_FOLDER}/p_MiModule_v00.conf -i CD.brio 
${ROOT_FOLDER}/root -l -b Job33_eff.cpp

cp efficiency_count.root $WORK_FOLDER/efficiency_count.root
# cp Default.root $WORK_FOLDER/Default_count.root
rm Default.root
rm efficiency_count.root

echo " ls after root1" 
ls -lh

${FAL}/flreconstruct -i CD.brio -p ${MAIN_FOLDER}/SNCuts_conf/SNCutsPipeline.conf -o CD.brio

cp ${MAIN_FOLDER}/Job33.cpp .
cp Job33.cpp ${WORK_FOLDER}/Job33.cpp

${FAL}/flreconstruct -p ${MAIN_FOLDER}/p_MiModule_v00.conf -i CD.brio 
${ROOT_FOLDER}/root -l -b Job33.cpp

cp efficiency.root ${WORK_FOLDER}/efficiency.root
# cp Default.root ${WORK_FOLDER}/Default.root
rm Default.root
rm efficiency.root

ls -lh 

end=`date +%s`
runtime=$((end-start))
echo " RUNTIME IS :"
echo $runtime
