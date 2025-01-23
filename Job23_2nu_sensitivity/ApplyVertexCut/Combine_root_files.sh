#!/bin/bash

# SLURM options:

#SBATCH --job-name=combV         	 # Job name
#SBATCH --partition=htc                  # Partition choice (most generally we work with htc, but for quick debugging you can use
										 #					 #SBATCH --partition=flash. This avoids waiting times, but is limited to 1hr)
#SBATCH --mem=16G                     	 # RAM
#SBATCH --licenses=sps                   # When working on sps, must declare license!!

#SBATCH --chdir=$TMPDIR
#SBATCH --time=0-3                 	 	 # Time for the job in format “minutes:seconds” or  “hours:minutes:seconds”, “days-hours”
#SBATCH --cpus-per-task=1                # Number of CPUs
	
## ABSOLUTE LINKING:
	MAIN_DIR=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster_sim_data/DataWithBField
	ROOT_FOLDER=/sps/nemo/sw/BxCppDev/opt/root-6.16.00/bin
# Run_script


# Iterate over simulation folders

for sim_folder in $MAIN_DIR/Job23*; do
    echo $sim_folder
    if [ -d "$sim_folder" ]; then
        echo "Processing simulation folder: $sim_folder"

        if [ -e "$sim_folder/0/EnePhiDist_Job23_SDBDRC_vertexCut_100mm.root" ]; then
            echo "$sim_folder/0/EnePhiDist_Job23_SDBDRC_vertexCut_100mm.root exists!"
            
            /sps/nemo/sw/BxCppDev/opt/root-6.16.00/bin/hadd -f $sim_folder/combined_vertex_cut.root $sim_folder/*/EnePhiDist_Job23_SDBDRC_vertexCut_100mm.root
        fi
    fi
done
