#!/bin/sh

# SLURM options:

#SBATCH --job-name=2ubb_testScript       # Job name
#SBATCH --partition=htc                  # Partition choice (most generally we work with htc, but for quick debugging you can use
										 #					 #SBATCH --partition=flash. This avoids waiting times, but is limited to 1hr)
#SBATCH --mem=8096M                      # RAM
#SBATCH --licenses=sps                   # When working on sps, must declare license!!

echo "================================="
echo "run_script started:"

pwd
ls

echo "================================="


echo "STARTING flsimulate:"
%FAL/flsimulate -c %MAIN_FOLDER/%USER_FOLDNAME/simu.conf -o %MAIN_FOLDER/%USER_FOLDNAME/SD.brio 
echo "FINISHED flsimulate."


echo "STARTING flreconstruct 1:"
%FAL/flreconstruct -i %MAIN_FOLDER/%USER_FOLDNAME/SD.brio -p %CONF_FOLDER/rec.conf -o %MAIN_FOLDER/%USER_FOLDNAME/CD.brio
echo "FINISHED flreconstruct 1."


echo "STARTED flreconstruct 2:"
%FAL/flreconstruct -p %CONF_FOLDER/p_MiModule_v00.conf -i %MAIN_FOLDER/%USER_FOLDNAME/CD.brio 
echo "FINISHED flreconstruct 2!"

