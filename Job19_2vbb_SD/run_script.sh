#!/bin/sh

# SLURM options:

#SBATCH --job-name=2ubbFal             	 # Job name
#SBATCH --partition=flash                  # Partition choice (most generally we work with htc, but for quick debugging you can use
										 #					 #SBATCH --partition=flash. This avoids waiting times, but is limited to 1hr)
#SBATCH --mem=16192M                     # RAM
#SBATCH --licenses=sps                   # When working on sps, must declare license!!

#SBATCH --chdir=$TMPDIR                  # To run in temporary directory (this will be deleted after job is done)
#SBATCH --time=0-1                  	 # Time for the job in format “minutes:seconds” or  “hours:minutes:seconds”, “days-hours”
#SBATCH --cpus-per-task=1                # Number of CPUs

echo "================================="
echo "run_script started:"
start=`date +%s`

pwd
ls

echo "================================="


echo "STARTING flsimulate:"
%FAL/flsimulate -c %MAIN_FOLDER/%USER_FOLDNAME/%i/simu.conf -o SD.brio 

echo "ls after flsimulate."
ls
echo "FINISHED flsimulate."


echo "STARTING flreconstruct 1:"
%FAL/flreconstruct -i SD.brio -p %CONF_FOLDER/rec.conf -o CD.brio

echo "ls after flreconstruct 1."
ls
echo "FINISHED flreconstruct 1."

ls -l
rm SD.brio

echo "STARTED flreconstruct 2:"
%FAL/flreconstruct -p %CONF_FOLDER/p_MiModule_v00.conf -i CD.brio 
echo "FINISHED flreconstruct 2!"

rm CD.brio

ls -l

echo "FINISHED simulation, STARTING analysis!"

pwd
ls -la
echo "==================="

echo "STARTED Job19.cpp:"

cp %CONF_FOLDER/Job19.cpp Job19.cpp

%ROOT_FOLDER/root -l -b Job19.cpp
echo "ls after Job19.cpp."
ls
echo "FINISHED Job19.cpp."

rm Default.root

cp SimulatedEneTheta.root %MAIN_FOLDER/%USER_FOLDNAME/%i/SimulatedEneTheta.root
# cp SD.brio %MAIN_FOLDER/%USER_FOLDNAME/%i/SD.brio
# cp CD.brio %MAIN_FOLDER/%USER_FOLDNAME/%i/CD.brio
# cp Default.root %MAIN_FOLDER/%USER_FOLDNAME/%i/Default.root

end=`date +%s`

runtime=$((end-start))
echo " RUNTIME IS :"
echo $runtime
