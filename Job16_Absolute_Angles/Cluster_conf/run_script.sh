#!/bin/sh

# SLURM options:

#SBATCH --job-name=AbsAng1e2              	 # Job name
#SBATCH --partition=htc                  # Partition choice (most generally we work with htc, but for quick debugging you can use
										 #					 #SBATCH --partition=flash. This avoids waiting times, but is limited to 1hr)
#SBATCH --mem=16192M                     # RAM
#SBATCH --licenses=sps                   # When working on sps, must declare license!!

#SBATCH --chdir=$TMPDIR                  # To run in temporary directory (this will be deleted after job is done)

echo "================================="
echo "run_script started:"
start=`date +%s`

pwd
ls

echo "================================="

echo "STARTED generating .genbb files:"
%JULIA/julia %MAIN_FOLDER/%USER_FOLDNAME/%i/genbbGenerator.jl
echo "FINISHED generating .genbb files:"
echo "================================="
cp $TMPDIR/input_module.genbb %MAIN_FOLDER/%USER_FOLDNAME/%i/


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

echo "STARTED Job16.cpp:"

cp %CONF_FOLDER/Job16.cpp Job16.cpp

%ROOT_FOLDER/root -l -b Job16.cpp
echo "ls after Job16.cpp."
ls
echo "FINISHED Job16.cpp."

rm Default.root

cp MomPosEneThetaPhi_1e6pf.root %MAIN_FOLDER/%USER_FOLDNAME/%i/MomPosEneThetaPhi_1e6pf.root

end=`date +%s`

runtime=$((end-start))
echo " RUNTIME IS :"
echo $runtime
