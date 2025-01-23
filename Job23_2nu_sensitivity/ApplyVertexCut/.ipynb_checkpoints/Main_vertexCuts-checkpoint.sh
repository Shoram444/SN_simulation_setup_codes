#!/bin/bash
	
## ABSOLUTE LINKING:
	CONF_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job23_2nu_sensitivity/ApplyVertexCut
	FAL=/sps/nemo/scratch/mpetro/PROGRAMS/Falaise/install/bin
	MAIN_DIR=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster_sim_data/DataWithBField/Job23_RH_K037_foil_bulk
	ROOT_FOLDER=/sps/nemo/sw/BxCppDev/opt/root-6.16.00/bin
	RUN_SCRIPT_DIR=/pbs/home/m/mpetro/Projects/PhD/Codes/Job23_2nu_sensitivity/ApplyVertexCut
# Run_script


# Iterate over simulation folders
# for sim_folder in "$MAIN_DIR"/Job23_simulation_*; do

for sim_folder in $MAIN_DIR/0; do
    echo $sim_folder
    if [ -d "$sim_folder" ]; then
        echo "Processing simulation folder: $sim_folder"

        # Iterate over subfolders within the simulation folder
        for subfolder in $sim_folder/*; do
            echo $subfolder
            if [ -d "$subfolder" ]; then
                echo "Processing subfolder: $subfolder"

                cd $subfolder
                rm core.*

                # Copy the command script into the subfolder

                sed -e "s|%subfolder|$subfolder|g" \
                    -e "s|%FAL|$FAL|g" \
                    -e "s|%CONF_FOLDER|$CONF_FOLDER|g" \
                    -e "s|%ROOT_FOLDER|$ROOT_FOLDER|g" \
				    $RUN_SCRIPT_DIR/run_vertexCuts.sh > $subfolder/run_vertexCuts.sh

                cp "$CONF_FOLDER/SNCutsPipeline_vertexCut.conf" "$subfolder/SNCutsPipeline_vertexCut.conf"

                # Change to the subfolder
                cd "$subfolder" || exit

                # Perform the set of commands within the subfolder
				chmod 755 $subfolder/run_vertexCuts.sh
                sbatch -o $subfolder/OUT_vertexCut.log -e $subfolder/ERR_vertexCut.log $subfolder/run_vertexCuts.sh 

                # Change back to the main simulation folder
                cd "$sim_folder" || exit
            fi
        done
    fi
done
