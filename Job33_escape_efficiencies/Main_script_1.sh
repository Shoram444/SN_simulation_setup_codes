#!/bin/bash

# ABSOLUTE LINKING
FAL=/sps/nemo/sw/redhat-9-x86_64/snsw/opt/falaise-5.1.2/bin
DATA_FOLDER=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster_sim_data
MAIN_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job33_escape_efficiencies
ROOT_FOLDER=/sps/nemo/sw/redhat-9-x86_64/snsw/opt/root-6.26.06/bin

# User input
echo "Number of events to simulate?: "
read NSIM

echo "Choose the name of simulation folder:"
read USER_FOLDNAME

echo "Choose number of files per combination:"
read FILES

# Define energy and thickness arrays
ENERGIES=(500)
THICKNESSES=(100)

# Total combinations
TOTAL_COMBINATIONS=$(( ${#ENERGIES[@]} * ${#THICKNESSES[@]} ))
TOTAL_TASKS=$(( TOTAL_COMBINATIONS * FILES ))

echo "Total combinations: $TOTAL_COMBINATIONS"
echo "Total tasks (files): $TOTAL_TASKS"

# Create main folder
if [ ! -d "$DATA_FOLDER/$USER_FOLDNAME" ]; then
    mkdir -p "$DATA_FOLDER/$USER_FOLDNAME"
else
    echo "Warning: Folder already exists. Continuing with existing data."
fi

# Prepare simulation directories
for ENERGY in "${ENERGIES[@]}"; do
    for THICKNESS in "${THICKNESSES[@]}"; do
        for (( f=0; f<FILES; f++ )); do
            COMB_FOLDER=$DATA_FOLDER/$USER_FOLDNAME/${ENERGY}keV_${THICKNESS}um/$f
            mkdir -p $COMB_FOLDER

            # Prepare files as before
            cp $MAIN_FOLDER/Job33.cpp $COMB_FOLDER/Job33.cpp

            sed -e "s|%ENERGY|$ENERGY|" \
                -e "s|%THICKNESS|$THICKNESS|g" \
                $MAIN_FOLDER/falaise_conf/variant.profile > $COMB_FOLDER/E_${ENERGY}_f_${THICKNESS}.profile

            sed -e "s|%NSIM|$NSIM|" \
                -e "s|%COMB_FOLDER|$COMB_FOLDER|g" \
                -e "s|%ENERGY|$ENERGY|g" \
                -e "s|%THICKNESS|$THICKNESS|g" \
                $MAIN_FOLDER/falaise_conf/simu.conf > $COMB_FOLDER/simu.conf
        done
    done
done

# Submit the array job

echo "FILES_PER_COMB: $FILES"
echo "TOTAL_COMBINATIONS: $TOTAL_COMBINATIONS"
echo "USER_FOLDNAME: $USER_FOLDNAME"
echo "MAIN_FOLDER: $MAIN_FOLDER"

echo "Submitting array job with $TOTAL_TASKS tasks"
sbatch --array=0-$(( TOTAL_TASKS - 1 )) \
    --export=ALL,FILES_PER_COMB="$FILES",TOTAL_COMBINATIONS="$TOTAL_COMBINATIONS",USER_FOLDNAME="$USER_FOLDNAME",MAIN_FOLDER="$MAIN_FOLDER",FAL="$FAL",ROOT_FOLDER="$ROOT_FOLDER" \
    -o ${DATA_FOLDER}/$USER_FOLDNAME/out_%A_%a.log -e ${DATA_FOLDER}/$USER_FOLDNAME/err_%A_%a.log \
    run_script_1.sh
