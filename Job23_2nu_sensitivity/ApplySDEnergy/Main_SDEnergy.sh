#!/bin/bash
	
## ABSOLUTE LINKING:
	CONF_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job23_2nu_sensitivity/ApplySDEnergy
	FAL=/sps/nemo/scratch/mpetro/PROGRAMS/Falaise/install/bin
	MAIN_DIR=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster_sim_data/DataWithBField/Job23_Bi214_foil_surface
	ROOT_FOLDER=/sps/nemo/sw/BxCppDev/opt/root-6.16.00/bin
# Run_script


# Copy the command script into the subfolder
sed -e "s|%FAL|$FAL|g" \
    -e "s|%CONF_FOLDER|$CONF_FOLDER|g" \
    -e "s|%MAIN_DIR|$MAIN_DIR|g" \
    -e "s|%ROOT_FOLDER|$ROOT_FOLDER|g" \
    $CONF_FOLDER/run_SDEnergy.sh > $MAIN_DIR/run_SDEnergy.sh

# Perform the set of commands within the subfolder
chmod 755 $MAIN_DIR/run_SDEnergy.sh
sbatch -o $MAIN_DIR/OUT_SDEnergy.log -e $MAIN_DIR/ERR_SDEnergy.log $MAIN_DIR/run_SDEnergy.sh 
