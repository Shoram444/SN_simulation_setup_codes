#!/bin/sh

# SLURM options:

#SBATCH --job-name=%ISO%SOURCE         	 # Job name
#SBATCH --partition=flash                  # Partition choice (most generally we work with htc, but for quick debugging you can use
										 #					 #SBATCH --partition=flash. This avoids waiting times, but is limited to 1hr)
#SBATCH --mem=16G                     	 # RAM
#SBATCH --licenses=sps                   # When working on sps, must declare license!!

#SBATCH --output=/dev/null    # Redirect stdout to /dev/null
#SBATCH --error=/dev/null     # Redirect stderr to /dev/null

#SBATCH --chdir=/tmp
#SBATCH --time=0-1                 	 # Time for the job in format “minutes:seconds” or  “hours:minutes:seconds”, “days-hours”
#SBATCH --cpus-per-task=1                # Number of CPUs

echo "================================="
echo "run_script started:"
start=`date +%s`

echo "Working in directory: "
pwd
echo "================================="
echo "STARTING simulation!"


%FAL/flsimulate -c %DATA_FOLDER/%USER_FOLDNAME/%f/%ISO.conf -o SD.brio 

# # WHEN USING CAT
# %FAL/flreconstruct -i SD.brio -p %MAIN_FOLDER/official-4.0.conf -o CD_CAT.brio

# # WHEN USING TIT
# %FAL/flreconstruct -i SD.brio -p %MAIN_FOLDER/MockCalibratePipeline.conf -o CD.brio
# %FAL/flreconstruct -i CD.brio -p %MAIN_FOLDER/TKReconstructPipeline.conf -o CD.brio
# %FAL/flreconstruct -i CD.brio -p %MAIN_FOLDER/PTD_tracking.conf -o CD_TIT.brio


# %FAL/flreconstruct -i CD_TIT.brio -p %MAIN_FOLDER/SNCutsPipeline.conf -o CDCut_TIT.brio
# %FAL/flreconstruct -i CD_CAT.brio -p %MAIN_FOLDER/SNCutsPipeline.conf -o CDCut_CAT.brio

# cp CDCut.brio %DATA_FOLDER/%USER_FOLDNAME/%f/CDCut_TIT.brio              # if you want to keep CD.brio
# cp CDCut.brio %DATA_FOLDER/%USER_FOLDNAME/%f/CDCut_CAT.brio              # if you want to keep CD.brio

# echo "================================="
# echo "FINISHED simulation, STARTING analysis!"
# ls -l

# %FAL/flreconstruct -p %MAIN_FOLDER/p_MiModule_v00.conf -i CDCut_CAT.brio 
# cp %MAIN_FOLDER/Job23.cpp Job23.cpp

# %ROOT_FOLDER/root -l -b Job23.cpp

# cp EnePhiDist_Job23.root %DATA_FOLDER/%USER_FOLDNAME/%f/CAT.root
# rm Default.root
# rm EnePhiDist_Job23.root

# %FAL/flreconstruct -p %MAIN_FOLDER/p_MiModule_v00.conf -i CDCut_TIT.brio 
# %ROOT_FOLDER/root -l -b Job23.cpp

# cp EnePhiDist_Job23.root %DATA_FOLDER/%USER_FOLDNAME/%f/TIT.root
# rm Default.root
# rm EnePhiDist_Job23.root

end=`date +%s`

runtime=$((end-start))
echo " RUNTIME IS :"
echo $runtime
