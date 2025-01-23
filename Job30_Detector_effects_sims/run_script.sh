#!/bin/sh

# SLURM options:

#SBATCH --job-name=J30_flat         	 # Job name
#SBATCH --partition=htc                  # Partition choice (most generally we work with htc, but for quick debugging you can use
										 #					 #SBATCH --partition=flash. This avoids waiting times, but is limited to 1hr)
#SBATCH --mem=32G                     	 # RAM
#SBATCH --licenses=sps                   # When working on sps, must declare license!!

#SBATCH --output=/dev/null    # Redirect stdout to /dev/null
#SBATCH --error=/dev/null     # Redirect stderr to /dev/null

#SBATCH --chdir=/tmp
#SBATCH --time=3-0                 	 # Time for the job in format “minutes:seconds” or  “hours:minutes:seconds”, “days-hours”
#SBATCH --cpus-per-task=1                # Number of CPUs


echo "================================="
echo "run_script started:"
start=`date +%s`

echo "Working in directory: "
pwd
echo "================================="
echo "STARTING simulation!"


%FAL/flsimulate -c %DATA_FOLDER/%USER_FOLDNAME/%f/simu.conf -o SD.brio 

# WHEN USING CAT
%FAL/flreconstruct -i SD.brio -p %MAIN_FOLDER/CAT_conf/CAT_reco.conf -o CD_CAT.brio

# WHEN USING TIT
%FAL/flreconstruct -i SD.brio -p %MAIN_FOLDER/TIT_conf/MockCalibratePipeline.conf -o CD.brio
%FAL/flreconstruct -i CD.brio -p %MAIN_FOLDER/TIT_conf/TKReconstructPipeline.conf -o CD.brio
%FAL/flreconstruct -i CD.brio -p %MAIN_FOLDER/TIT_conf/PTD_tracking.conf -o CD_TIT.brio


%FAL/flreconstruct -i CD_TIT.brio -p %MAIN_FOLDER/SNCuts_conf/SNCutsPipeline.conf -o CDCut_TIT.brio
%FAL/flreconstruct -i CD_CAT.brio -p %MAIN_FOLDER/SNCuts_conf/SNCutsPipeline.conf -o CDCut_CAT.brio

cp SD.brio %DATA_FOLDER/%USER_FOLDNAME/%f/SD.brio              # if you want to keep CD.brio
cp CDCut_TIT.brio %DATA_FOLDER/%USER_FOLDNAME/%f/CDCut_TIT.brio              # if you want to keep CD.brio
cp CDCut_CAT.brio %DATA_FOLDER/%USER_FOLDNAME/%f/CDCut_CAT.brio              # if you want to keep CD.brio

echo "================================="
echo "FINISHED simulation, STARTING analysis!"
ls -l

%FAL/flreconstruct -p %MAIN_FOLDER/p_MiModule_v00.conf -i CDCut_CAT.brio 
cp %MAIN_FOLDER/Job31.cpp Job31.cpp

%ROOT_FOLDER/root -l -b Job31.cpp

cp reco_data.root %DATA_FOLDER/%USER_FOLDNAME/%f/CAT.root
rm Default.root
rm reco_data.root


%FAL/flreconstruct -p %MAIN_FOLDER/p_MiModule_v00.conf -i CDCut_TIT.brio 
%ROOT_FOLDER/root -l -b Job31.cpp

cp reco_data.root %DATA_FOLDER/%USER_FOLDNAME/%f/TIT.root
rm Default.root
rm reco_data.root

end=`date +%s`

runtime=$((end-start))
echo " RUNTIME IS :"
echo $runtime
