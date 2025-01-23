#!/bin/sh

# SLURM options:

#SBATCH --job-name=SDE              	 # Job name
#SBATCH --partition=htc                  # Partition choice (most generally we work with htc, but for quick debugging you can use
										 #					 #SBATCH --partition=flash. This avoids waiting times, but is limited to 1hr)
#SBATCH --mem=8G                     	 # RAM
#SBATCH --licenses=sps                   # When working on sps, must declare license!!

#SBATCH --time=0-4                	 	 # Time for the job in format “minutes:seconds” or  “hours:minutes:seconds”, “days-hours”
#SBATCH --cpus-per-task=1                # Number of CPUs


for subfolder in %MAIN_DIR/*; do
    if [ -d "$subfolder" ]; then
        echo "Processing subfolder: $subfolder"
		cd $subfolder

		rm core.*
        rm Job23.cpp
        rm EnePhiDist_Job23_SDBDRC_vertex_prob_SD.root

		cp %CONF_FOLDER/Job23.cpp $subfolder/Job23.cpp

		if [ -e "Default.root" ]; then
			rm Default.root
		fi
		if [ -e "EnePhiDist_Job23.root" ]; then
			rm EnePhiDist_Job23.root
		fi

		if [ -e "CDCut_vertex_probability.brio" ]; then
			%FAL/flreconstruct -i CDCut_vertex_probability.brio -p %CONF_FOLDER/p_MiModule_v00.conf
		fi
		if [ -e "CDCut_probability.brio" ]; then
			%FAL/flreconstruct -i CDCut_probability.brio -p %CONF_FOLDER/p_MiModule_v00.conf
		fi


		%ROOT_FOLDER/root -l -b Job23.cpp
		mv $subfolder/EnePhiDist_Job23.root $subfolder/EnePhiDist_Job23_SDBDRC_vertex_prob_SD.root
	fi
done
