#!/bin/sh

# SLURM options:

#SBATCH --job-name=eff         	 # Job name
#SBATCH --partition=flash                  # Partition choice (most generally we work with htc, but for quick debugging you can use
										 #					 #SBATCH --partition=flash. This avoids waiting times, but is limited to 1hr)
#SBATCH --mem=32G                     	 # RAM
#SBATCH --licenses=sps                   # When working on sps, must declare license!!

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

%FAL/flreconstruct -i SD.brio -p %MAIN_FOLDER/SNCuts_conf/Escaped1.conf -o SD.brio

# WHEN USING TIT
%FAL/flreconstruct -i SD.brio -p %MAIN_FOLDER/TIT_conf/MockCalibratePipeline.conf -o CD.brio
%FAL/flreconstruct -i CD.brio -p %MAIN_FOLDER/TIT_conf/TKReconstructPipeline.conf -o CD.brio
%FAL/flreconstruct -i CD.brio -p %MAIN_FOLDER/TIT_conf/PTD_tracking.conf -o CD.brio


# cp SD.brio %DATA_FOLDER/%USER_FOLDNAME/%f/SD.brio              # if you want to keep CD.brio
# cp CD.brio %DATA_FOLDER/%USER_FOLDNAME/%f/CD.brio              # if you want to keep CD.brio

echo "================================="
echo "FINISHED simulation, STARTING analysis!"
pwd
ls -lh

cp %MAIN_FOLDER/Job33_eff.cpp .
cp Job33_eff.cpp %DATA_FOLDER/%USER_FOLDNAME/%f/Job33_eff.cpp

%FAL/flreconstruct -p %MAIN_FOLDER/p_MiModule_v00.conf -i CD.brio 
%ROOT_FOLDER/root -l -b Job33_eff.cpp

cp efficiency_count.root %DATA_FOLDER/%USER_FOLDNAME/%f/efficiency_count.root
cp Default.root %DATA_FOLDER/%USER_FOLDNAME/%f/Default_count.root
rm Default.root
rm efficiency_count.root

pwd
ls -lh

%FAL/flreconstruct -i CD.brio -p %MAIN_FOLDER/SNCuts_conf/SNCutsPipeline.conf -o CD.brio

cp %MAIN_FOLDER/Job33.cpp .
cp Job33.cpp %DATA_FOLDER/%USER_FOLDNAME/%f/Job33.cpp

%FAL/flreconstruct -p %MAIN_FOLDER/p_MiModule_v00.conf -i CD.brio 
%ROOT_FOLDER/root -l -b Job33.cpp

cp efficiency.root %DATA_FOLDER/%USER_FOLDNAME/%f/efficiency.root
cp Default.root %DATA_FOLDER/%USER_FOLDNAME/%f/Default.root
rm Default.root
rm efficiency.root

pwd
ls -lh

end=`date +%s`

runtime=$((end-start))
echo " RUNTIME IS :"
echo $runtime
