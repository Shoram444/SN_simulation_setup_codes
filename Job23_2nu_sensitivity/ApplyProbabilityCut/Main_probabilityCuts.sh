#!/bin/bash
	
## ABSOLUTE LINKING:
	CONF_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job23_2nu_sensitivity/ApplyProbabilityCut
	FAL=/sps/nemo/scratch/mpetro/PROGRAMS/Falaise/install/bin
	MAIN_DIR=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster/DataWithBField
	ROOT_FOLDER=/sps/nemo/sw/BxCppDev/opt/root-6.16.00/bin
# Run_script


# Iterate over simulation folders
# for sim_folder in "$MAIN_DIR"/Job23_simulation_*; do

for sim_folder in $MAIN_DIR/Job23_Xi037_foil_bulk/0; do
    echo $sim_folder
    if [ -d "$sim_folder" ]; then
        echo "Processing simulation folder: $sim_folder"

        # Iterate over subfolders within the simulation folder
        for subfolder in $sim_folder/*; do
            echo $subfolder
            if [ -d "$subfolder" ]; then
                echo "Processing subfolder: $subfolder"

                Copy the command script into the subfolder

                sed -e "s|%subfolder|$subfolder|g" \
                    -e "s|%FAL|$FAL|g" \
                    -e "s|%CONF_FOLDER|$CONF_FOLDER|g" \
                    -e "s|%ROOT_FOLDER|$ROOT_FOLDER|g" \
				    $CONF_FOLDER/run_probabilityCut.sh > $subfolder/run_probabilityCut.sh

                cp "$CONF_FOLDER/SNCutsPipeline_probabilityCut.conf" "$subfolder/SNCutsPipeline_probabilityCut.conf"

                # Change to the subfolder
                cd "$subfolder" || exit

                # Perform the set of commands within the subfolder
				chmod 755 $subfolder/run_probabilityCut.sh
                sbatch -o $subfolder/OUT_probabilityCut.log -e $subfolder/ERR_probabilityCut.log $subfolder/run_probabilityCut.sh 

                # Change back to the main simulation folder
                cd "$sim_folder" || exit
            fi
        done
    fi
done
